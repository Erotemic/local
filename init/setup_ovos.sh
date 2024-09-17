#!/usr/bin/env bash
__doc__='
References:
    https://openvoiceos.github.io/ovos-docker/
    https://github.com/OpenVoiceOS/ovos-installer
    https://community.openconversational.ai/t/howto-begin-your-open-voice-os-journey-with-the-ovos-installer/14900

    https://openvoiceos.github.io/ovos-technical-manual/

Blind Install:
    sh -c "curl -s https://raw.githubusercontent.com/OpenVoiceOS/ovos-installer/main/installer.sh -o installer.sh && chmod +x installer.sh && sudo ./installer.sh && rm installer.sh"

    sh -c "curl -s https://raw.githubusercontent.com/OpenVoiceOS/ovos-installer/main/installer.sh -o installer.sh && chmod +x installer.sh && sudo ./installer.sh && rm installer.sh"


Misc:
    sudo apt install linux-tools-common linux-tools-`uname -r`
    sudo apt install linux-tools-common linux-tools-`uname -r` --reinstall



'
cd "$HOME"/code
git clone https://github.com/OpenVoiceOS/ovos-installer.git

cd "$HOME"/code/ovos-installer

mkdir -p ~/.config/ovos-installer
cat <<EOF > ~/.config/ovos-installer/scenario.yaml
---
uninstall: false
method: virtualenv
channel: development
profile: ovos
features:
  skills: true
  extra_skills: false
  gui: false
rapsberry_pi_tuning: true
share_telemetry: true
EOF

sudo ./setup.sh -d --reuse-cached-artifacts

inspect(){
    cat utils/constants.sh
    cat utils/banner.sh
    cat utils/common.sh
    cat utils/argparse.sh
    cat setup.sh
}

developer_setup(){

    deactivate
    source "$HOME"/.venvs/ovos/bin/activate

    cd ~/code
    git clone https://github.com/OpenVoiceOS/ovos-core.git
    git clone https://github.com/OpenVoiceOS/ovos-audio.git
    git clone https://github.com/OpenVoiceOS/ovos-dinkum-listener.git
    git clone https://github.com/LostLightProjects/jellyfin-skill.git

    cd ~/code/ovos-dinkum-listener
    pip uninstall ovos_dinkum_listener
    systemctl --user restart ovos-listener.service
    systemctl --user status ovos-listener.service
}

debuggin(){
    systemctl --user status "ovos*"
    systemctl --user list-units "ovos*"
    journalctl -u "ovos*" -b
    journalctl -u "ovos*" -b --no-pager
}


tmux_logs(){
    # optional, kill all tmux sessions before starting
    #tmux kill-server

    # A bash array of the service names to monitor
    SERVICE_NAMES=(
        ovos-audio.service
        ovos-core.service
        ovos-ggwave-listener.service
        ovos-listener.service
        ovos-messagebus.service
        ovos-phal.service
        ovos.service
    )
    INDEX=0
    for SERVICE_NAME in "${SERVICE_NAMES[@]}"; do
        # Tmux session names cannot contain a ".", so remove it
        SESSION_NAME="monitor-$(echo "$SERVICE_NAME" | cut -d "." -f 1)"
        printf "Spinup logs %d: %s to monitor service: %s\n" "$INDEX" "$SESSION_NAME" "$SERVICE_NAME"
        # Kill the existing tmux session if it exists
        tmux kill-session -t "${SESSION_NAME}"  > /dev/null 2>&1 || true
        # Start a fresh shell in a tmux session
        tmux new-session -d -s "${SESSION_NAME}" "/bin/bash"
        # Send the logging command to the tmux session
        tmux send -t "${SESSION_NAME}" "journalctl --user --follow --unit ${SERVICE_NAME}" Enter
        INDEX=$((INDEX + 1))
    done
}


setup_inside_docker(){
    __doc__="
    "

    docker pull ubuntu:24.04

    docker create --name=ovos-sandbox --interactive --device /dev/snd:/dev/snd ubuntu:24.04 /bin/bash
    docker start ovos-sandbox
    docker ps -a
    docker exec -it ovos-sandbox /bin/bash

    export DEBIAN_FRONTEND=noninteractive
    sudo apt update
    sudo apt install git curl python3 -y

    mkdir -p "$HOME"/code
    cd "$HOME"/code
    git clone https://github.com/OpenVoiceOS/ovos-installer.git
    cd "$HOME"/code/ovos-installer

mkdir -p ~/.config/ovos-installer
cat <<EOF > ~/.config/ovos-installer/scenario.yaml
---
uninstall: false
method: virtualenv
channel: development
profile: ovos
features:
  skills: true
  extra_skills: false
  gui: false
rapsberry_pi_tuning: false
share_telemetry: false
EOF
sudo ./setup.sh

    docker stop ovos-sandbox
    docker rm ovos-sandbox

}

speedup(){
    # https://github.com/OpenVoiceOS/ovos-stt-plugin-chromium
    # https://github.com/OscillateLabsLLC/ovos-rust-messagebus
    git clone https://github.com/OscillateLabsLLC/ovos-rust-messagebus
    cd ovos-rust-messagebus

}
