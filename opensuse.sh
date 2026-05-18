#!/bin/bash

install_system_deps() {
  echo "  - vim (gvim)"

  sudo zypper refresh
  sudo zypper install -y dconf util-linux

  sudo zypper install -y rsync \
    the_silver_searcher \
    git \
    xclip \
    patterns-devel-base-devel_basis \
    zsh \
    gvim \
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

install_tmux() {
  echo "Installing tmux"
  sudo zypper install -y tmux
}

install_gnome_terminal_colors() {
  if [[ -z "${TERMINAL}" ]]; then
    TERMINAL=gnome-terminal bash -c "$(curl -sSLo- https://raw.githubusercontent.com/Mayccoll/Gogh/master/gogh.sh)"
  else
    bash -c "$(curl -sSLo- https://raw.githubusercontent.com/Mayccoll/Gogh/master/gogh.sh)"
  fi
}

install_docker() {
  # Remove old Docker versions
  sudo zypper remove -y docker docker-engine

  # Add Docker repository
  # OpenSUSE uses the SLES Docker repository
  sudo zypper addrepo https://download.docker.com/linux/sles/docker-ce.repo
  sudo zypper refresh

  # Install Docker packages
  sudo zypper install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

  # Enable and start Docker service
  sudo systemctl enable docker
  sudo systemctl start docker

  # Add user to docker group
  sudo usermod -aG docker "$(whoami)"
}

install_system_deps
install_tmux

if [ -z "${CI:-}" ]; then
  install_gnome_terminal_colors
fi

if [ "${SKIP_DOCKER:-}" != "1" ]; then
  install_docker
fi

sudo zypper clean
