# Source common shell settings
source "$HOME/shell-common"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"

# Completion configuration
if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi
# Source Oh My Zsh aliases
[ -f "$HOME/aliases-git.sh" ] && source "$HOME/aliases-git.sh"
[ -f "$HOME/aliases-kubectl.sh" ] && source "$HOME/aliases-kubectl.sh"

# Better Tab Completion (readline settings)
# https://askubuntu.com/a/1063994
bind "set completion-ignore-case on"
bind "set show-all-if-ambiguous on"

# Auto cd - type directory name to cd into it
shopt -s autocd

# History configuration
HISTFILE=$HOME/.bash_history
HISTFILESIZE=10000
shopt -s histappend
export HISTCONTROL=ignoreboth

# Colored Prompt
# Shell:User @ Host : Directory ($/#)
# Blue Shell, Cyan User, Green Host, Blue Directory, $/#
# Use "toolbox" if running with unknown UID (e.g., debug containers with random UID)
_ps1_user=$(id -un 2>/dev/null || echo "toolbox")
[[ "$_ps1_user" == "I have no name!" ]] && _ps1_user="toolbox"
export PS1='\[\033[01;34m\](bash)\[\033[00m\] \[\033[01;36m\]$_ps1_user\[\033[00m\]@\[\033[01;32m\]toolbox\[\033[00m\]:\[\033[01;34m\]$PWD\[\033[00m\]
\$ '

# FZF Keybindings (Homebrew Path)
[ -f ${HOMEBREW_PREFIX}/opt/fzf/shell/completion.bash ] && source ${HOMEBREW_PREFIX}/opt/fzf/shell/completion.bash
[ -f ${HOMEBREW_PREFIX}/opt/fzf/shell/key-bindings.bash ] && source ${HOMEBREW_PREFIX}/opt/fzf/shell/key-bindings.bash
