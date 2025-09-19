# Ask Claude Code from the CLI

A shell function that lets you ask a quick question to Claude Code with natural language arguments.

It runs Claude Code in an isolated directory to prevent it from reading or accessing your current directory. This means that you cannot ask questions about your current directory or its content.

## What it does

The `ask` function:

1. Creates and switches to `~/.claude-ask`
2. Runs `claude -p` with your arguments
3. Returns to your original directory

## Usage

You can use:

```bash
$ ask how to use gh cli to obtain the current repo url, only the url
```

The output would be something like this:

````
You can use the following command:
```bash
gh repo view --json url --jq .url
```
````

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
