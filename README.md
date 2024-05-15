# Lazy.tmux

Lazy.tmux is a wrapper around [tpm](https://github.com/tmux-plugins/tpm)
that provides a more intuitive and nicer way to manage your Tmux plugins.

Lazy.tmux is inspired by [lazy.nvim](https://github.com/folke/lazy.nvim) if you're
using nvim and not using lazy.nvim, go give it a try!

![image](./img/lazy.png)

⚠️  WARNING: lazy.tmux is still in early development stages. Some unintended behavior might occur.
If you encounter any issue, please report it so I may fix it.

## 📜 Prerequisites

- [tpm](https://github.com/tmux-plugins/tpm)
- [gum](https://github.com/charmbracelet/gum)

## 📥 Installation

Add this to your `.tmux.conf` and run `Ctrl-I` for TPM to install the plugin.

```conf
set -g @plugin 'IdoKendo/tmux-lazy'
```

This is going to be the last time you need to do this 😉.

## ⚙️  Configuration

The default binding to open lazy.tmux is `<prefix>+Z`
You can change it by adding this line with your desired key:

```bash
set -g @lazy-tmux-binding '<mykey>'
```

## 🕹️ Usage

Launching lazy.tmux opens a "pop up" with a fuzzy finder of actions and installed plugins.
You can fuzzy find the action that you want or the plugin that you wish to update and click Enter.

Available options:

- `Install New Plugins` will open up a text box to add a new plugin to your tmux.conf file
- `Update All Plugins` will update all plugins currently installed.
- `Clean Stale Plugins` will delete artifacts of plugins that are not currently in-use.
- Selecting any plugin name will update it to its latest version. Note that `(new commit)` tag will appear on plugins that have new commits.
- `Exit` will close lazy.tmux; This is also possible by clicking the `Esc` key.
