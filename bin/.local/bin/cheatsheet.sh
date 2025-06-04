#!/usr/bin/env bash

if [ ! -f "$HOME/.local/cht.sh" ]; then
    echo "Installing cht.sh"
    mkdir -p "$HOME/.local/bin"
    curl https://cht.sh/:cht.sh > "$HOME/.local/bin/cht.sh"
    chmod +x "$HOME/.local/bin/cht.sh"
    echo "cht.sh installed"
fi

languages=(
    "bash"
    "lua"
    "rust"
    "python"
    "javascript"
    "php"
    "c"
    "go"
)

core_utils=(
    "awk"
    "sed"
    "grep"
    "find"
    "xargs"
    "tar"
    "curl"
    "wget"
    "ssh"
    "tmux"
)
