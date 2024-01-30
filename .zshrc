# Personal Zsh configuration file. It is strongly recommended to keep all
# shell customization and configuration (including exported environment
# variables such as PATH) in this file or in files sourced from it.
#
# Documentation: https://github.com/tacgnol/zsh4doug/blob/master/README.md.

# Periodic auto-update on Zsh startup: 'ask' or 'no'.
# You can manually run `z4d update` to update everything.
zstyle ':z4d:' auto-update      'no'
# Ask whether to auto-update this often; has no effect if auto-update is 'no'.
zstyle ':z4d:' auto-update-days '28'

# Keyboard type: 'mac' or 'pc'.
zstyle ':z4d:bindkey' keyboard  'pc'

# Mark up shell's output with semantic information.
zstyle ':z4d:' term-shell-integration 'yes'

# Right-arrow key accepts one character ('partial-accept') from
# command autosuggestions or the whole thing ('accept')?
zstyle ':z4d:autosuggestions' forward-char 'accept'

# Recursively traverse directories when TAB-completing files.
zstyle ':z4d:fzf-complete' recurse-dirs 'no'

# Enable direnv to automatically source .envrc files.
zstyle ':z4d:direnv'         enable 'no'
# Show "loading" and "unloading" notifications from direnv.
zstyle ':z4d:direnv:success' notify 'yes'

# Enable ('yes') or disable ('no') automatic teleportation of z4d over
# SSH when connecting to these hosts.
zstyle ':z4d:ssh:example-hostname1'   enable 'yes'
zstyle ':z4d:ssh:*.example-hostname2' enable 'no'
# The default value if none of the overrides above match the hostname.
zstyle ':z4d:ssh:*'                   enable 'no'

# Send these files over to the remote host when connecting over SSH to the
# enabled hosts.
zstyle ':z4d:ssh:*' send-extra-files '~/.nanorc' '~/.env.zsh'

# Clone additional Git repositories from GitHub.
#
# This doesn't do anything apart from cloning the repository and keeping it
# up-to-date. Cloned files can be used after `z4d init`. This is just an
# example. If you don't plan to use Oh My Zsh, delete this line.
z4d install ohmyzsh/ohmyzsh || return

# Install or update core components (fzf, zsh-autosuggestions, etc.) and
# initialize Zsh. After this point console I/O is unavailable until Zsh
# is fully initialized. Everything that requires user interaction or can
# perform network I/O must be done above. Everything else is best done below.
z4d init || return

# Extend PATH.
path=(~/bin $path)

# Export environment variables.
export GPG_TTY=$TTY

# Source additional local files if they exist.
z4d source ~/.env.zsh

# Use additional Git repositories pulled in with `z4d install`.
#
# This is just an example that you should delete. It does nothing useful.
z4d source ohmyzsh/ohmyzsh/lib/diagnostics.zsh  # source an individual file
z4d load   ohmyzsh/ohmyzsh/plugins/emoji-clock  # load a plugin

# Define key bindings.
z4d bindkey z4d-backward-kill-word  Ctrl+Backspace     Ctrl+H
z4d bindkey z4d-backward-kill-zword Ctrl+Alt+Backspace

z4d bindkey undo Ctrl+/ Shift+Tab  # undo the last command line change
z4d bindkey redo Alt+/             # redo the last undone command line change

z4d bindkey z4d-cd-back    Alt+Left   # cd into the previous directory
z4d bindkey z4d-cd-forward Alt+Right  # cd into the next directory
z4d bindkey z4d-cd-up      Alt+Up     # cd into the parent directory
z4d bindkey z4d-cd-down    Alt+Down   # cd into a child directory

# Autoload functions.
autoload -Uz zmv

# Define functions and completions.
function md() { [[ $# == 1 ]] && mkdir -p -- "$1" && cd -- "$1" }
compdef _directories md

# Define named directories: ~w <=> Windows home directory on WSL.
[[ -z $z4d_win_home ]] || hash -d w=$z4d_win_home

# Define aliases.
alias tree='tree -a -I .git'

# Add flags to existing aliases.
alias ls="${aliases[ls]:-ls} -A"

# Set shell options: http://zsh.sourceforge.net/Doc/Release/Options.html.
setopt glob_dots     # no special treatment for file names with a leading dot
setopt no_auto_menu  # require an extra TAB press to open the completion menu
