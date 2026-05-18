#!/bin/bash
# Test cc_dotfiles installation on OpenSUSE using Docker
#
# Requires: Docker (https://www.docker.com)
#
# Usage:
#   ./tests/test_opensuse.sh            # run tests in OpenSUSE container
#   ./tests/test_opensuse.sh interactive # run interactive shell in container

set -eu

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
IMAGE="opensuse/tumbleweed"

if [ "${1:-}" = "interactive" ]; then
  echo "Starting interactive OpenSUSE container..."
  echo "Run: cd /workspace && LOCAL_INSTALL=1 CI=true bash install.sh"
  docker run -it --rm -v "$PROJECT_DIR":/workspace -w /workspace "$IMAGE" /bin/bash
  exit 0
fi

echo "Testing cc_dotfiles on OpenSUSE Tumbleweed..."
echo "Project directory: $PROJECT_DIR"
echo ""

docker run --rm -v "$PROJECT_DIR":/workspace -w /workspace "$IMAGE" /bin/bash -c '
  set -eu
  echo "=== Installing prerequisites ==="
  zypper install -y curl sudo

  echo ""
  echo "=== Running dotfiles installation ==="
  LOCAL_INSTALL=1 CI=true SKIP_DOCKER=1 bash install.sh

  echo ""
  echo "=== Verifying installation ==="

  # Check symlinks
  test -L ~/.aliases && echo "✓ ~/.aliases symlink created" || echo "✗ ~/.aliases missing"
  test -L ~/.zshrc && echo "✓ ~/.zshrc symlink created" || echo "✗ ~/.zshrc missing"
  test -L ~/.vimrc && echo "✓ ~/.vimrc symlink created" || echo "✗ ~/.vimrc missing"
  test -L ~/.tmux.conf && echo "✓ ~/.tmux.conf symlink created" || echo "✗ ~/.tmux.conf missing"
  test -L ~/.gitconfig && echo "✓ ~/.gitconfig symlink created" || echo "✗ ~/.gitconfig missing"

  # Check vim-plug
  test -f ~/.vim/autoload/plug.vim && echo "✓ vim-plug installed" || echo "✗ vim-plug missing"

  # Check mise
  test -f ~/.local/bin/mise && echo "✓ mise installed" || echo "✗ mise missing"

  # Check tools
  command -v git >/dev/null && echo "✓ git installed" || echo "✗ git missing"
  command -v tmux >/dev/null && echo "✓ tmux installed" || echo "✗ tmux missing"
  command -v vim >/dev/null && echo "✓ vim installed" || echo "✗ vim missing"
  command -v ag >/dev/null && echo "✓ ag (silver searcher) installed" || echo "✗ ag missing"
  command -v zsh >/dev/null && echo "✓ zsh installed" || echo "✗ zsh missing"

  # Check vim clipboard support
  vim --version | grep -q "+clipboard" && echo "✓ vim has clipboard support" || echo "✗ vim missing clipboard support"

  echo ""
  echo "=== Test completed ==="
'

echo ""
echo "Done! All tests completed."
echo ""
echo "To run an interactive test session, use:"
echo "  ./tests/test_opensuse.sh interactive"
