#!/bin/bash
set -eu

if [ -d "$HOME/.cc_dotfiles" ]; then
  echo "You already have Campus Code Dotfiles installed."
  exit 0
fi

echo "Installing Campus Code Dotfiles"
echo "We'll install:"
echo "  - zsh, tmux, vim, git, silver searcher"
echo "  - mise with Ruby and Node.js"
echo "  - dotfiles configuration (symlinks, plugins, fonts)"

if [ -z "${LOCAL_INSTALL:-}" ]; then
  echo "Installing from remote source"
  if ! command -v git > /dev/null 2>&1; then
    case "$(uname -s)" in
      Linux)
        if grep -q "^ID=ubuntu" /etc/os-release 2>/dev/null; then
          sudo apt-get update
          sudo apt-get install -y git
        elif grep -qE "^ID.*opensuse" /etc/os-release 2>/dev/null; then
          sudo zypper refresh
          sudo zypper install -y git
        fi
        ;;
    esac
  fi
  git clone --depth=10 https://github.com/campuscode/cc_dotfiles.git "$HOME/.cc_dotfiles"
else
  echo "Installing from local source"
  if ! command -v rsync > /dev/null 2>&1; then
    case "$(uname -s)" in
      Linux)
        if grep -q "^ID=ubuntu" /etc/os-release 2>/dev/null; then
          sudo apt-get update
          sudo apt-get install -y rsync
        elif grep -qE "^ID.*opensuse" /etc/os-release 2>/dev/null; then
          sudo zypper refresh
          sudo zypper install -y rsync
        fi
        ;;
      Darwin)
        # rsync is pre-installed on macOS
        ;;
    esac
  fi
  rsync -a --no-perms --exclude='.vagrant' --exclude='tags' --exclude='vim/autoload' --exclude='vim/bundle' --exclude='vim/backups' . "$HOME/.cc_dotfiles"
  curl -fLo "$HOME/.cc_dotfiles/vim/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

case "$(uname -s)" in
  Linux)
    if grep -q "^ID=ubuntu" /etc/os-release 2>/dev/null; then
      bash "$HOME/.cc_dotfiles/ubuntu.sh"
    elif grep -qE "^ID.*opensuse" /etc/os-release 2>/dev/null; then
      bash "$HOME/.cc_dotfiles/opensuse.sh"
    else
      echo "Linux distribution not supported. Supported: Ubuntu, OpenSUSE"
      exit 1
    fi
    ;;
  Darwin)
    bash "$HOME/.cc_dotfiles/mac.sh"
    eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
    ;;
  *)
    echo "Operational system not supported, aborting installation"
    exit 1
    ;;
esac

# Install mise with Ruby and Node.js — common to all platforms
curl https://mise.run | sh
eval "$(~/.local/bin/mise activate bash)"
mise settings ruby.compile=false
mise use --global ruby
mise use --global node

cd "$HOME/.cc_dotfiles"
rake install

