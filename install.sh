#!/bin/bash

# Install script for the ask function

# Verify required CLI is available
if ! command -v claude >/dev/null 2>&1; then
    echo "Error: 'claude' CLI not found in PATH. Please install the Claude CLI and try again."
    exit 1
fi

# Detect current shell
SHELL_NAME=$(basename "$SHELL")

# Function definitions
BASH_ZSH_FUNCTION='ask() {
    mkdir -p ~/.claude-ask
    pushd ~/.claude-ask > /dev/null
    if [ $# -eq 0 ]; then
        echo "Ask Claude Code:"
        read -r input
        claude -p "$input"
    else
        claude -p "$*"
    fi
    popd > /dev/null
}'

FISH_FUNCTION='function ask
    mkdir -p ~/.claude-ask
    pushd ~/.claude-ask
    if test (count $argv) -eq 0
        echo "Ask Claude Code:"
        read -l input
        claude -p "$input"
    else
        claude -p "$argv"
    end
    popd
end'

echo "Detected shell: $SHELL_NAME"

case "$SHELL_NAME" in
    "bash")
        CONFIG_FILE="$HOME/.bashrc"
        FUNCTION_TO_ADD="$BASH_ZSH_FUNCTION"
        ;;
    "zsh")
        CONFIG_FILE="$HOME/.zshrc"
        FUNCTION_TO_ADD="$BASH_ZSH_FUNCTION"
        ;;
    "fish")
        CONFIG_FILE="$HOME/.config/fish/config.fish"
        FUNCTION_TO_ADD="$FISH_FUNCTION"
        # Ensure fish config directory exists
        mkdir -p "$HOME/.config/fish"
        ;;
    *)
        echo "Unsupported shell: $SHELL_NAME"
        echo "Please install manually following the README instructions."
        exit 1
        ;;
esac

# Check if function already exists and remove it
FUNCTION_EXISTS=false
if grep -q "ask()" "$CONFIG_FILE" 2>/dev/null || grep -q "function ask" "$CONFIG_FILE" 2>/dev/null; then
    FUNCTION_EXISTS=true
    echo "Ask function already exists in $CONFIG_FILE - updating..."

    # Remove existing function and comment
    if [ "$SHELL_NAME" = "fish" ]; then
        # Remove fish function block
        sed -i.bak '/# Ask function - added by install script/,/^end$/d' "$CONFIG_FILE" 2>/dev/null || true
        sed -i.bak '/^function ask$/,/^end$/d' "$CONFIG_FILE" 2>/dev/null || true
    else
        # Remove bash/zsh function block
        sed -i.bak '/# Ask function - added by install script/,/^}$/d' "$CONFIG_FILE" 2>/dev/null || true
        sed -i.bak '/^ask() {$/,/^}$/d' "$CONFIG_FILE" 2>/dev/null || true
    fi

    # Clean up backup file
    rm -f "$CONFIG_FILE.bak" 2>/dev/null || true
else
    echo "Installing ask function to $CONFIG_FILE..."
fi

# Add function to config file
if [ "$FUNCTION_EXISTS" = false ]; then
    echo "" >> "$CONFIG_FILE"
fi
echo "# Ask function - added by install script" >> "$CONFIG_FILE"
echo "$FUNCTION_TO_ADD" >> "$CONFIG_FILE"

# Create the ~/.claude-ask directory structure
echo "Setting up ~/.claude-ask directory..."
mkdir -p "$HOME/.claude-ask/.claude"

# Copy settings file if it exists
if [ -f "claude-ask-settings.json" ]; then
    cp "claude-ask-settings.json" "$HOME/.claude-ask/.claude/settings.local.json"
    echo "Copied Claude settings to ~/.claude-ask/.claude/settings.local.json"
else
    echo "Warning: claude-ask-settings.json not found in current directory"
fi

echo "Ask function installed successfully!"

# Provide clear instructions to activate the function without auto-sourcing
echo ""
echo "Next steps:"
if [ "$SHELL_NAME" = "fish" ]; then
    echo "- Run: source $CONFIG_FILE"
    echo "  or restart your shell to start using 'ask'."
else
    echo "- Run: source $CONFIG_FILE"
    echo "  or restart your shell to start using 'ask'."
fi
echo ""
echo "Then try: ask hello world"
