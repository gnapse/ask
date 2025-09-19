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

You can also just type `ask` without arguments for interactive input. Interactive mode reads until EOF (Ctrl-D), so multi-line prompts work well and piped input is supported.

Examples:

```bash
# Multiline interactive prompt (finish with Ctrl-D)
ask
```

```bash
# Piped input
printf "line 1\nline 2\n" | ask
```

## Installation

Prerequisite: Ensure the `claude` CLI is available in your current shell (e.g., `claude --version`). If not, the `ask` function will print an error at runtime.

Run the install script:

```bash
./install.sh
```

Then restart your shell or run:

```bash
source ~/.bashrc                         # bash
source ~/.zshrc                          # zsh
source ~/.config/fish/functions/ask.fish # fish
```

The installer does not auto-source your shell configuration; it prints clear next steps instead. You can inspect the install script to see exactly what it does and perform the installation manually if preferred.

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

## Uninstall

- bash: remove the `ask` function block from `~/.bashrc` and restart your shell.
- zsh: remove the `ask` function block from `~/.zshrc` and restart your shell.
- fish: delete `~/.config/fish/functions/ask.fish` and restart fish.
- optional: remove the workspace: `rm -rf ~/.claude-ask`.
