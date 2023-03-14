#!/usr/bin/env python3
"""
Attestation duties are known for current + next epoch. Proposal duties are
known for current epoch.

python3 ~/local/tools/get_validator_duties.py

Referenes:
    https://ethereum.github.io/beacon-APIs/#/
    https://gist.github.com/pietjepuk2/eb021db978ad20bfd94dce485be63150

"""
import math
from datetime import datetime, timedelta

import requests
try:
    from rich import print
except ImportError:
    ...


SLOTS_PER_EPOCH = 32
SECONDS_PER_SLOT = 12

ETH2_API_URL = "http://localhost:5052/eth/v1/"


def main(validators_indices='auto', eth2_api_url=ETH2_API_URL):
    r"""
    """
    def api_get(endpoint):
        return requests.get(f"{eth2_api_url}{endpoint}")

    def api_post(endpoint, data):
        return requests.post(f"{eth2_api_url}{endpoint}", json=data)

    if validators_indices == 'auto':
        validators_indices = list(find_validator_index())

    resp = api_get("beacon/headers/head")
    head_slot = int(resp.json()["data"]["header"]["message"]["slot"])
    epoch = head_slot // SLOTS_PER_EPOCH

    endpoint = f"validator/duties/attester/{epoch}"
    validators_indices = list(map(str, validators_indices))
    resp = api_post(endpoint, validators_indices)

    cur_epoch_data = resp.json()[
        "data"
    ]
    resp = api_post(
        f"validator/duties/attester/{epoch + 1}", validators_indices
    )
    next_epoch_data = resp.json()["data"]

    genesis_timestamp = 1606824023

    attestation_duties = {}
    for d in (*cur_epoch_data, *next_epoch_data):
        attestation_duties.setdefault(int(d["slot"]), []).append(d["validator_index"])
    attestation_duties = {k: v for k, v in sorted(attestation_duties.items()) if k > head_slot}

    all_proposer_duties = api_get(f"validator/duties/proposer/{epoch}").json()["data"]

    validators_indices_set = set(validators_indices)
    duties = attestation_duties.copy()
    for s in all_proposer_duties:
        slot = int(s["slot"])
        if slot <= head_slot:
            continue

        prop_index = int(s["validator_index"])
        if prop_index in validators_indices_set:
            duties.setdefault(slot, []).append(f"{prop_index} (proposal)")

    duties = dict(sorted(duties.items()))

    # Also insert (still unknown) attestation duties at epoch after next,
    # assuming worst case of having to attest at its first slot
    first_slot_epoch_p2 = (epoch + 2) * SLOTS_PER_EPOCH
    attestation_duties[first_slot_epoch_p2] = []

    print("Calculating attestation/proposal slots and gaps for validators:")
    print(f"  {validators_indices}")

    print("\nUpcoming voting/proposal slots and gaps")
    print("(Gap in seconds)")
    print("(slot/epoch - time range - validators)")
    print("*" * 80)

    prev_end_time = datetime.now()
    # Floor to seconds
    prev_end_time = datetime(*datetime.utctimetuple(prev_end_time)[:6])

    # Current epoch gaps
    cur_epoch_gap_store = {"longest_gap": timedelta(seconds=0), "gap_time_range": (None, None)}
    overall_gap_store = cur_epoch_gap_store.copy()

    next_epoch_start_slot = (epoch + 1) * SLOTS_PER_EPOCH
    next_epoch_start_time = datetime.fromtimestamp(genesis_timestamp + next_epoch_start_slot * 12.0)

    in_next_epoch = False

    def humanize_timedelta(delta):
        sign = math.copysign(1, delta.total_seconds())
        return ('' if sign >= 0 else '-') + str(abs(delta))

    def _update_gap(end, start, gap_store):
        gap = end - start
        assert gap.total_seconds() >= 0
        if gap > gap_store["longest_gap"]:
            gap_store["longest_gap"] = gap
            gap_store["gap_time_range"] = (end, start)

    for slot, validators in duties.items():
        slot_start = datetime.fromtimestamp(genesis_timestamp + slot * SECONDS_PER_SLOT)
        slot_end = slot_start + timedelta(seconds=SECONDS_PER_SLOT)

        suf = ""
        if not in_next_epoch and slot >= next_epoch_start_slot:
            epoch_change_delta = humanize_timedelta(next_epoch_start_time - prev_end_time)
            print("- " * 40)
            print(
                f"Time until epoch change: {epoch_change_delta}"
            )
            print(
                f"Epoch boundary (proposal duties are not yet known for next epoch): {next_epoch_start_time}"
            )
            print(
                f"Time until next duty: {humanize_timedelta((slot_start - next_epoch_start_time))} seconds"
            )
            print("- " * 40)
            suf = "(after prev. slot duty or current time)"

            _update_gap(next_epoch_start_time, prev_end_time, cur_epoch_gap_store)
            in_next_epoch = True

        print(f"Gap - {humanize_timedelta(slot_start - prev_end_time)} {suf}")

        if validators:
            print(
                f"  {slot}/{slot // SLOTS_PER_EPOCH}"
                f" - {slot_start.strftime('%H:%M:%S')} until {slot_end.strftime('%H:%M:%S')}"
                f" - [{', '.join(validators)}]"
            )
        else:
            assert slot % SLOTS_PER_EPOCH == 0

        _update_gap(slot_start, prev_end_time, overall_gap_store)
        if in_next_epoch is False:
            _update_gap(slot_start, prev_end_time, cur_epoch_gap_store)

        prev_end_time = slot_end

    print("\nLongest attestation and proposer duty gap (only current epoch, first):")
    longest_gap, gap_time_range = cur_epoch_gap_store.values()
    print("*" * 80)
    print(
        f"{humanize_timedelta(longest_gap)} "
        f" ({int(longest_gap.total_seconds()) // SECONDS_PER_SLOT} slots),"
        f" from {gap_time_range[1].strftime('%H:%M:%S')}"
        f" until {gap_time_range[0].strftime('%H:%M:%S')}"
    )

    print("\nLongest attestation gap (first):")
    longest_gap, gap_time_range = overall_gap_store.values()
    print("*" * 80)
    print(
        f"{humanize_timedelta(longest_gap)}"
        f" ({int(longest_gap.total_seconds()) // SECONDS_PER_SLOT} slots),"
        f" from {gap_time_range[1].strftime('%H:%M:%S')}"
        f" until {gap_time_range[0].strftime('%H:%M:%S')}"
    )


def find_validator_index():
    import subprocess
    out = subprocess.check_output(['rocketpool', 'minipool', 'status']).decode('utf8')
    for line in out.split('\n'):
        if 'Validator index:' in line:
            index = int(line.split(':')[-1].strip())
            yield index


if __name__ == "__main__":
    import argparse

    # To get your index:
    '''
    rocketpool minipool status | grep Validator.index
    '''
    eth2_api_url = ETH2_API_URL

    parser = argparse.ArgumentParser(
        description="Show validator duties of current and next epoch to find largest gap."
    )
    parser.add_argument("indices", metavar="index", type=int, nargs="*", help="validator indices", default='auto')

    args = parser.parse_args()

    main(args.indices)
