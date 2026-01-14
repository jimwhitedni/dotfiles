#!/bin/bash
set -e
echo "🚀 開始安裝 dotfiles..."

# 1. 安裝 Homebrew（如果沒有）
if ! command -v brew &> /dev/null; then
  echo "📦 安裝 Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# 2. 安裝工具
echo "📦 安裝工具..."
brew install fzf zoxide zsh-autosuggestions eza bat ripgrep fd neovim

# 3. 安裝 Ghostty
echo "👻 安裝 Ghostty..."
brew install --cask ghostty

# 4. 安裝字體
echo "🔤 安裝字體..."
brew install --cask font-jetbrains-mono-nerd-font

# 5. 建立 symlinks
echo "🔗 建立 symlinks..."

# zshrc
ln -sf ~/dotfiles/.zshrc ~/.zshrc

# Ghostty
mkdir -p ~/.config/ghostty
ln -sf ~/dotfiles/ghostty.config ~/.config/ghostty/config

# Neovim
mkdir -p ~/.config
ln -sf ~/dotfiles/nvim ~/.config/nvim

# 6. 載入設定
echo "✅ 完成！請執行: source ~/.zshrc"
echo "📝 首次打開 nvim 會自動安裝插件"
