# Oh My Zsh Common Aliases



# Git Aliases (git plugin)
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gap='git add --patch'
alias gau='git add --update'
alias gav='git add --verbose'
alias gb='git branch'
alias gba='git branch -a'
alias gbd='git branch -d'
alias gbD='git branch -D'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gc='git commit -v'
alias gca='git commit -v -a'
alias gcam='git commit -a -m'
alias gcm='git checkout $(git_main_branch)'
alias gd='git diff'
alias gdca='git diff --cached'
alias gds='git diff --staged'
alias gf='git fetch'
alias gl='git pull'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gr='git remote'
alias gra='git remote add'
alias grv='git remote -v'
alias gst='git status'
alias gss='git status -s'
alias gsb='git status -sb'
alias glo='git log --oneline --decorate'
alias glog='git log --oneline --decorate --graph'
alias glol='git log --graph --pretty='\''%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'\'''

# Git Main Branch Function
function git_main_branch() {
  command git rev-parse --git-dir &>/dev/null || return
  local ref
  for ref in refs/heads/main refs/heads/master refs/heads/trunk; do
    if command git show-ref -q --verify $ref; then
      echo ${ref:t}
      return
    fi
  done
  echo master
}
