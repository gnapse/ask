#!/bin/bash

# Install script for the ask function

# No install-time dependency checks; assume 'claude' exists at runtime

# Detect current shell
SHELL_NAME=$(basename "$SHELL")

# Function definitions
BASH_ZSH_FUNCTION='ask() {
    if ! command -v claude >/dev/null 2>&1; then
        echo "Error: 'claude' command not found in this shell. Please install or make it available before using 'ask'."
        return 127
    fi
    if [ $# -eq 0 ]; then
        printf "Ask Claude Code (end with Ctrl-D):\n"
        input="$(cat)"
        ( mkdir -p ~/.claude-ask && cd ~/.claude-ask && claude -p "$input" )
    else
        prompt="$*"
        ( mkdir -p ~/.claude-ask && cd ~/.claude-ask && claude -p "$prompt" )
    fi
}'

FISH_FUNCTION='function ask
    if not type -q claude
        echo "Error: 'claude' command not found in this shell. Please install or make it available before using 'ask'."
        return 127
    end
    set -l prev (pwd)
    mkdir -p ~/.claude-ask
    cd ~/.claude-ask
    if test (count $argv) -eq 0
        echo "Ask Claude Code (end with Ctrl-D):"
        set -l input (cat)
        claude -p "$input"
    else
        set -l prompt (string join " " -- $argv)
        claude -p "$prompt"
    end
    cd $prev
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
        # Install fish function as a dedicated file for clean management
        CONFIG_FILE="$HOME/.config/fish/functions/ask.fish"
        FUNCTION_TO_ADD="$FISH_FUNCTION"
        mkdir -p "$HOME/.config/fish/functions"
        ;;
    *)
        echo "Unsupported shell: $SHELL_NAME"
        echo "Please install manually following the README instructions."
        exit 1
        ;;
esac

MARKER='# Ask function - added by install script'

if [ "$SHELL_NAME" = "fish" ]; then
    # Manage a dedicated fish function file
    if [ -f "$CONFIG_FILE" ]; then
        if grep -q "$MARKER" "$CONFIG_FILE" 2>/dev/null; then
            echo "Updating existing 'ask' fish function installed by this script in $CONFIG_FILE..."
        else
            echo "Warning: existing fish function found at $CONFIG_FILE. Backing up to $CONFIG_FILE.bak and replacing with this script's version."
            cp "$CONFIG_FILE" "$CONFIG_FILE.bak" 2>/dev/null || true
        fi
    else
        echo "Installing ask function to $CONFIG_FILE..."
    fi
    {
        echo "$MARKER"
        echo "$FUNCTION_TO_ADD"
    } > "$CONFIG_FILE"
else
    # Check for existing function blocks and remove only our installed block (bash/zsh)
    OUR_BLOCK_EXISTS=false
    OTHER_ASK_EXISTS=false
    if grep -q "$MARKER" "$CONFIG_FILE" 2>/dev/null; then
        OUR_BLOCK_EXISTS=true
        echo "Updating existing 'ask' function installed by this script in $CONFIG_FILE..."
        sed -i.bak "/$MARKER/,/^}$/d" "$CONFIG_FILE" 2>/dev/null || true
        rm -f "$CONFIG_FILE.bak" 2>/dev/null || true
    else
        if grep -q "^ask() {" "$CONFIG_FILE" 2>/dev/null; then
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
    echo "$MARKER" >> "$CONFIG_FILE"
    echo "$FUNCTION_TO_ADD" >> "$CONFIG_FILE"
fi

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
