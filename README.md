# Ask Function

A shell function that lets you run Claude in a specific directory with natural language arguments.

## What it does

The `ask` function:
1. Creates and switches to `~/.claude-ask`
2. Runs `claude -p` with your arguments
3. Returns to your original directory

## Usage

Instead of:
```bash
claude -p "what is 2 plus 2"
```

You can use:
```bash
ask what is 2 plus 2
```

## Installation

Run the install script:
```bash
./install.sh
```

Then restart your shell or run:
```bash
source ~/.bashrc   # for bash
source ~/.zshrc    # for zsh
source ~/.config/fish/config.fish   # for fish
```

## Manual Installation

### Bash/Zsh
Add to `~/.bashrc` or `~/.zshrc`:
```bash
ask() {
    mkdir -p ~/.claude-ask
    pushd ~/.claude-ask > /dev/null
    claude -p "$*"
    popd > /dev/null
}
```

### Fish
Add to `~/.config/fish/config.fish`:
```fish
function ask
    mkdir -p ~/.claude-ask
    pushd ~/.claude-ask
    claude -p "$argv"
    popd
end
```