#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)

STD="&>/dev/null"

function header_info {
clear
cat <<"EOF"
    __    __    __    __    ______
   / /   / /   / /   / /   / ____/
  / /   / /   / /   / /   / /     
 / /___/ /___/ /___/ /___/ /___   
/_____/_/_____/_/_____/_/_____/   
                                  
EOF
}
header_info
echo -e "Loading..."
APP="llama-cpp"
var_disk="20"
var_cpu="4"
var_ram="8192"
var_os="ubuntu"
var_version="22.04"
variables
color
catch_errors

function default_settings() {
  CT_TYPE="1"
  PW=""
  CT_ID=$NEXTID
  HN=$NSAPP
  DISK_SIZE="$var_disk"
  CORE_COUNT="$var_cpu"
  RAM_SIZE="$var_ram"
  BRG="vmbr0"
  NET="dhcp"
  GATE=""
  APT_CACHER=""
  APT_CACHER_IP=""
  DISABLEIP6="no"
  MTU=""
  SD=""
  NS=""
  MAC=""
  VLAN=""
  SSH="no"
  VERB="no"
  echo_default
}

function install_dependencies() {
  msg_info "Installing Dependencies"
  $STD apt-get update
  $STD apt-get install -y build-essential cmake python3 python3-pip git
  msg_ok "Installed Dependencies"
}

function clone_llama_cpp() {
  msg_info "Cloning llama.cpp Repository"
  cd /opt
  $STD git clone https://github.com/ggerganov/llama.cpp.git
  cd llama.cpp
  msg_ok "Cloned llama.cpp Repository"
}

function build_llama_cpp() {
  msg_info "Building llama.cpp"
  $STD mkdir build
  cd build
  $STD cmake ..
  $STD make
  msg_ok "Built llama.cpp"
}

function create_service() {
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
}

function expose_server() {
  msg_info "Exposing llama.cpp Server to the Network"
  ufw allow 8080/tcp
  msg_ok "Exposed llama.cpp Server to the Network"
}

start
build_container
description

install_dependencies
clone_llama_cpp
build_llama_cpp
create_service
expose_server

msg_ok "Completed Successfully!\n"
echo -e "${APP} should be reachable by going to the following URL.
         ${BL}http://${IP}:8080${CL} \n"
