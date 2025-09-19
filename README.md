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

You can also just type `ask` without arguments for interactive input. This is useful for questions containing special characters that would need escaping in the shell.

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

You can inspect the install script to see exactly what it does and perform the installation manually if preferred.

## Configuration

The installer sets up a minimal Claude Code configuration in `~/.claude-ask/.claude/settings.local.json` that allows only web search by default:

```json
{
  "permissions": {
    "allow": [
      "WebSearch"
    ],
    "deny": [],
    "ask": []
  }
}
```

You can modify this file to customize Claude Code's permissions for your `ask` sessions. For example, you might want to allow additional tools like:

- `"Bash(command --with args)"` - to run certain shell commands
- `"WebFetch(domain:example.com)"` - to allow fetching web pages from certain domains

Edit the file at `~/.claude-ask/.claude/settings.local.json` to adjust permissions to your needs. Remember that these permissions only apply to the isolated `ask` environment, not your regular Claude Code usage.
