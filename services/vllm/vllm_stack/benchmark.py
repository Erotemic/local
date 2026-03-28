from __future__ import annotations

import json
import statistics
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path
from typing import Any

import requests


DEFAULT_SYSTEM_PROMPT = "You are a concise, accurate assistant."


class BenchmarkError(RuntimeError):
    pass


def load_prompts(path: str | Path) -> list[dict[str, str]]:
    with Path(path).open("r", encoding="utf-8") as file:
        data = json.load(file)
    return list(data)


def build_prompt(target_tokens: int, seed_prompt: str) -> str:
    filler = (
        "alpha beta gamma delta epsilon zeta eta theta iota kappa lambda mu nu xi omicron pi rho sigma tau upsilon phi chi psi omega"
    )
    words = seed_prompt.split()
    while len(words) < target_tokens:
        words.extend(filler.split())
    return " ".join(words[:target_tokens])


def resolve_model(base_url: str, api_key: str) -> str:
    response = requests.get(
        f"{base_url.rstrip('/')}/models",
        headers={"Authorization": f"Bearer {api_key}"},
        timeout=30,
    )
    response.raise_for_status()
    data = response.json()
    models = data.get("data", [])
    if not models:
        raise BenchmarkError(f"No models exposed by {base_url}")
    return models[0]["id"]


def _non_stream_request(
    base_url: str,
    api_key: str,
    model: str,
    prompt: str,
    completion_tokens: int,
    timeout_s: int,
) -> dict[str, Any]:
    url = f"{base_url.rstrip('/')}/chat/completions"
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json",
    }
    payload = {
        "model": model,
        "messages": [
            {"role": "system", "content": DEFAULT_SYSTEM_PROMPT},
            {"role": "user", "content": prompt},
        ],
        "max_tokens": completion_tokens,
        "temperature": 0,
        "stream": False,
    }
    started = time.perf_counter()
    response = requests.post(url, headers=headers, json=payload, timeout=timeout_s)
    elapsed = time.perf_counter() - started
    response.raise_for_status()
    data = response.json()
    usage = data.get("usage", {})
    completion_used = int(usage.get("completion_tokens", completion_tokens))
    prompt_used = int(usage.get("prompt_tokens", 0))
    return {
        "latency_s": elapsed,
        "ttft_s": None,
        "prompt_tokens": prompt_used,
        "completion_tokens": completion_used,
        "output_tps": completion_used / max(elapsed, 1e-9),
    }


def _stream_request(
    base_url: str,
    api_key: str,
    model: str,
    prompt: str,
    completion_tokens: int,
    timeout_s: int,
) -> dict[str, Any]:
    url = f"{base_url.rstrip('/')}/chat/completions"
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json",
    }
    payload = {
        "model": model,
        "messages": [
            {"role": "system", "content": DEFAULT_SYSTEM_PROMPT},
            {"role": "user", "content": prompt},
        ],
        "max_tokens": completion_tokens,
        "temperature": 0,
        "stream": True,
        "stream_options": {"include_usage": True},
    }
    started = time.perf_counter()
    response = requests.post(url, headers=headers, json=payload, timeout=timeout_s, stream=True)
    response.raise_for_status()

    ttft = None
    usage = {}
    for raw_line in response.iter_lines(decode_unicode=True):
        if not raw_line:
            continue
        if not raw_line.startswith("data: "):
            continue
        body = raw_line[6:].strip()
        if body == "[DONE]":
            break
        packet = json.loads(body)
        if ttft is None:
            choices = packet.get("choices", [])
            if choices:
                delta = choices[0].get("delta", {})
                if delta.get("content"):
                    ttft = time.perf_counter() - started
        if packet.get("usage"):
            usage = packet["usage"]
    elapsed = time.perf_counter() - started
    completion_used = int(usage.get("completion_tokens", completion_tokens))
    prompt_used = int(usage.get("prompt_tokens", 0))
    return {
        "latency_s": elapsed,
        "ttft_s": ttft,
        "prompt_tokens": prompt_used,
        "completion_tokens": completion_used,
        "output_tps": completion_used / max(elapsed, 1e-9),
    }


def single_request(
    base_url: str,
    api_key: str,
    model: str,
    prompt: str,
    completion_tokens: int,
    timeout_s: int,
    stream: bool,
) -> dict[str, Any]:
    if stream:
        return _stream_request(base_url, api_key, model, prompt, completion_tokens, timeout_s)
    return _non_stream_request(base_url, api_key, model, prompt, completion_tokens, timeout_s)


def summarize_results(concurrency: int, results: list[dict[str, Any]]) -> dict[str, Any]:
    latencies = [r["latency_s"] for r in results]
    output_tps = [r["output_tps"] for r in results]
    completion_tokens = [r["completion_tokens"] for r in results]
    ttfts = [r["ttft_s"] for r in results if r.get("ttft_s") is not None]
    total_completion = sum(completion_tokens)
    total_elapsed = sum(latencies)
    return {
        "concurrency": concurrency,
        "requests": len(results),
        "latency_p50_s": statistics.median(latencies),
        "latency_p95_s": sorted(latencies)[max(0, int(len(latencies) * 0.95) - 1)],
        "output_tps_mean": statistics.mean(output_tps),
        "aggregate_output_tps": total_completion / max(total_elapsed / max(concurrency, 1), 1e-9),
        "ttft_p50_s": statistics.median(ttfts) if ttfts else None,
    }


def run_benchmark(
    base_url: str,
    api_key: str,
    model: str | None,
    prompts_file: str | Path,
    concurrency_levels: list[int],
    requests_per_level: int,
    prompt_tokens: int,
    completion_tokens: int,
    timeout_s: int,
    stream: bool,
) -> dict[str, Any]:
    prompts = load_prompts(prompts_file)
    if not model:
        model = resolve_model(base_url, api_key)

    rounds: list[dict[str, Any]] = []
    prompt_cycle = [build_prompt(prompt_tokens, item["prompt"]) for item in prompts]

    for concurrency in concurrency_levels:
        jobs: list[dict[str, Any]] = []
        with ThreadPoolExecutor(max_workers=concurrency) as executor:
            futures = []
            for idx in range(requests_per_level * concurrency):
                prompt = prompt_cycle[idx % len(prompt_cycle)]
                futures.append(
                    executor.submit(
                        single_request,
                        base_url,
                        api_key,
                        model,
                        prompt,
                        completion_tokens,
                        timeout_s,
                        stream,
                    )
                )
            for future in as_completed(futures):
                jobs.append(future.result())
        rounds.append(summarize_results(concurrency, jobs))

    latency_score = rounds[0]["latency_p50_s"]
    throughput_score = max(r["aggregate_output_tps"] for r in rounds)
    balanced_score = throughput_score / max(latency_score, 1e-9)

    return {
        "base_url": base_url,
        "model": model,
        "rounds": rounds,
        "scores": {
            "latency": 1.0 / max(latency_score, 1e-9),
            "throughput": throughput_score,
            "balanced": balanced_score,
        },
    }
