# Source common shell settings
source "$HOME/shell-common"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"

# Source Oh My Zsh aliases
[ -f "$HOME/aliases-git.sh" ] && source "$HOME/aliases-git.sh"
[ -f "$HOME/aliases-kubectl.sh" ] && source "$HOME/aliases-kubectl.sh"

alias curl='noglob curl'

# Completion configuration
autoload -Uz compinit
compinit -u
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Auto cd - type directory name to cd into it
setopt AUTO_CD

# History configuration
HISTFILE=$HOME/.zsh_history
SAVEHIST=10000
setopt APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# Colored Prompt
autoload -Uz colors && colors
setopt PROMPT_SUBST
# User @ Host : Directory $
# Use "toolbox" if running with unknown UID (e.g., debug containers with random UID)
_ps1_user=$(id -un 2>/dev/null || echo "toolbox")
[[ "$_ps1_user" == "I have no name!" ]] && _ps1_user="toolbox"
PROMPT='%F{blue}(zsh)%f %F{cyan}${_ps1_user}%f@%F{green}toolbox%f:%F{blue}%/%f
%(!.#.$) '

# Zsh Autosuggestions
if [ -f ${HOMEBREW_PREFIX}/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source ${HOMEBREW_PREFIX}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# Key bindings
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
bindkey "^[[3~" delete-char
bindkey "^[OH" beginning-of-line
bindkey "^[OF" end-of-line
bindkey "^[[2~" overwrite-mode
bindkey "^[[5~" beginning-of-buffer-or-history
bindkey "^[[6~" end-of-buffer-or-history
bindkey "^[[A" up-line-or-history
bindkey "^[[B" down-line-or-history
bindkey "^[[D" backward-char
bindkey "^[[C" forward-char

# FZF Keybindings (Homebrew Path)
[ -f ${HOMEBREW_PREFIX}/opt/fzf/shell/completion.zsh ] && source ${HOMEBREW_PREFIX}/opt/fzf/shell/completion.zsh
[ -f ${HOMEBREW_PREFIX}/opt/fzf/shell/key-bindings.zsh ] && source ${HOMEBREW_PREFIX}/opt/fzf/shell/key-bindings.zsh

# Zsh Syntax Highlighting (Must be last)
if [ -f ${HOMEBREW_PREFIX}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source ${HOMEBREW_PREFIX}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
