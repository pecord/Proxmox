#!/usr/bin/env bash

# Copyright (c) 2021-2024 tteck
# Author: tteck
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt-get install -y build-essential cmake python3 python3-pip git
msg_ok "Installed Dependencies"

msg_info "Cloning llama.cpp Repository"
cd /opt
$STD git clone https://github.com/ggerganov/llama.cpp.git
cd llama.cpp
msg_ok "Cloned llama.cpp Repository"

msg_info "Building llama.cpp"
$STD mkdir build
cd build
$STD cmake ..
$STD make
msg_ok "Built llama.cpp"

msg_info "Creating llama.cpp Service"
cat <<EOF >/etc/systemd/system/llama-cpp.service
[Unit]
Description=llama.cpp Service
After=network.target

[Service]
Type=simple
WorkingDirectory=/opt/llama.cpp
ExecStart=/opt/llama.cpp/build/bin/llama-cpp
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now llama-cpp.service
msg_ok "Created llama.cpp Service"

msg_info "Exposing llama.cpp Server to the Network"
ufw allow 8080/tcp
msg_ok "Exposed llama.cpp Server to the Network"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
