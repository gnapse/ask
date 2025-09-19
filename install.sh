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

# Check for existing function blocks and remove only our installed block
MARKER='# Ask function - added by install script'
OUR_BLOCK_EXISTS=false
OTHER_ASK_EXISTS=false

if grep -q "$MARKER" "$CONFIG_FILE" 2>/dev/null; then
    OUR_BLOCK_EXISTS=true
    echo "Updating existing 'ask' function installed by this script in $CONFIG_FILE..."
    if [ "$SHELL_NAME" = "fish" ]; then
        sed -i.bak "/$MARKER/,/^end$/d" "$CONFIG_FILE" 2>/dev/null || true
    else
        sed -i.bak "/$MARKER/,/^}$/d" "$CONFIG_FILE" 2>/dev/null || true
    fi
    rm -f "$CONFIG_FILE.bak" 2>/dev/null || true
else
    if grep -q "^ask() {" "$CONFIG_FILE" 2>/dev/null || grep -q "^function ask" "$CONFIG_FILE" 2>/dev/null; then
        OTHER_ASK_EXISTS=true
        echo "Warning: an existing 'ask' function is defined in $CONFIG_FILE and will not be modified."
        echo "The installed 'ask' function will be appended and take precedence in new shells."
    else
        echo "Installing ask function to $CONFIG_FILE..."
    fi
fi

# Add function to config file
if [ "$OUR_BLOCK_EXISTS" = false ] && [ "$OTHER_ASK_EXISTS" = false ]; then
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
