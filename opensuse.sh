#!/bin/bash

install_system_deps() {
  echo "  - Installing system dependencies"

  sudo zypper refresh

  # Install basic tools
  sudo zypper install -y \
    dconf \
    util-linux \
    git \
    xclip \
    zsh \
    vim \
    tmux \
    fontconfig

  # Add Base:System repo for libpcre1 and utilities repo for silver searcher
  sudo zypper addrepo https://download.opensuse.org/repositories/Base:/System/openSUSE_Tumbleweed/Base:System.repo || true
  sudo zypper addrepo https://download.opensuse.org/repositories/utilities/openSUSE_Factory/utilities.repo || true
  sudo zypper --gpg-auto-import-keys refresh

  # Install PCRE library (required by silver searcher) and silver searcher
  sudo zypper install -y libpcre1 the_silver_searcher || true

  # Install development tools
  sudo zypper install -y \
    patterns-devel-base-devel_basis \
    gcc \
    gcc-c++

  # Install development libraries for Ruby/Node.js
  sudo zypper install -y \
    libevent-devel \
    ncurses-devel \
    bison \
    pkg-config \
    libopenssl-devel \
    readline-devel \
    zlib-devel \
    libyaml-devel \
    libffi-devel
}

install_gnome_terminal_colors() {
  if [[ -z "${TERMINAL}" ]]; then
    TERMINAL=gnome-terminal bash -c "$(curl -sSLo- https://raw.githubusercontent.com/Mayccoll/Gogh/master/gogh.sh)"
  else
    bash -c "$(curl -sSLo- https://raw.githubusercontent.com/Mayccoll/Gogh/master/gogh.sh)"
  fi
}

install_docker() {
  # Install docker and docker-compose
  sudo zypper install docker docker-compose

  # Enable and start Docker service
  sudo systemctl enable docker
  sudo systemctl start docker

  # Add user to docker group
  sudo usermod -aG docker "$(whoami)"
}

install_system_deps

if [ -z "${CI:-}" ]; then
  install_gnome_terminal_colors
fi

if [ "${SKIP_DOCKER:-}" != "1" ]; then
  install_docker
fi

sudo zypper clean
