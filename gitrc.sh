#!/bin/bash

# Autocomplete
source "${GITRC_PATH}/scripts/git-completion.bash"
source "${GITRC_PATH}/scripts/git-flow-completion.bash"
__git_complete g _git
__git_complete gti _git
__git_complete qg _git
__git_complete gf _git_flow

# Prompt
source "${GITRC_PATH}/git_ps1.sh"

# git in English
alias git='LANGUAGE=en_US.UTF-8 git'

# Common misspell
alias gti='git'
alias gl='git l'
alias gll='git ll'
alias glg='git lg'
alias glgg='git lgg'
alias glll='git lll'
alias glllg='git lllg'
alias gst='git st'
alias gpush='git push'
alias gpull='git pull'

# git flow aliases
alias gf='git flow'

alias gff='git flow feature'
alias gffco='git flow feature checkout'
alias gffs='git flow feature start'
alias gfff='git flow feature finish'
alias gffph='git flow feature publish'
alias gffpl='git flow feature pull'
alias gfft='git flow feature track'

alias gfb='git flow bugfix'
alias gfbco='git flow bugfix checkout'
alias gfbs='git flow bugfix start'
alias gfbf='git flow bugfix finish'
alias gfbph='git flow bugfix publish'
alias gfbpl='git flow bugfix pull'
alias gfbt='git flow bugfix track'

alias gfr='git flow release'
alias gfrco='git flow release checkout'
alias gfrs='git flow release start'
alias gfrf='git flow release finish'
alias gfrph='git flow release publish'
alias gfrpl='git flow release pull'
alias gfrt='git flow release track'

alias gfh='git flow hotfix'
alias gfhco='git flow hotfix checkout'
alias gfhs='git flow hotfix start'
alias gfhf='git flow hotfix finish'
alias gfhph='git flow hotfix publish'
alias gfhpl='git flow hotfix pull'
alias gfht='git flow hotfix track'


export PATH=$PATH:${GITRC_PATH}/bin

# Checkout a branch with fallbacks on sub git repositories
cobr() {
  default_branches="develop master"

  branches_order=$*
  if [ $# -eq 0 ]; then
    echo "Need to provide at least 1 branch"
  else
    # Adding default branches at the end
    branches_order="${branches_order} ${default_branches}"

    for d in $(find . -name .git | sed 's@./@@; s@/.git@@')
    do
      # Apply command
      pushd "$d" > /dev/null;

      for b in ${branches_order}
      do
        if git checkout "$b" > /dev/null 2>&1
        then
          printf "%20s set to %s\n" "$d" "$b"
          break;
        fi
      done

      popd > /dev/null;
    done
  fi
}

# Find all commits (even in orphans) containing $1 in diff log.
function git_dig {
  if [ $# -eq 0 ]; then
    echo "Find all commits (even in orphans) containing $1 in diff log"
  else
    git rev-list --all | xargs git grep --threads 4 --color "$1"
    #git log --pretty=format:'%Cred%h%Creset - %Cgreen(%ad)%Creset - %s %C(bold blue)<%an>%Creset' --abbrev-commit --date=short -G"$1" -- $2
  fi
}

# Tag all git repositories under current path
# $1 is the tag name
# $2 is the tag comment
# $3 is the (optional) branch to use for tagging (master is default)
function tag_subgit {
  tagName=$1
  tagComment=${2}
  branchToTag=${3:-master}

  for d in $(find . -maxdepth 2 -name .git | sed 's@./@@; s@/.git@@')
  do
    pushd "$d" > /dev/null;

    # -s to sign commit
    LANG=en_US git tag -f -as "${tagName}" -m "${tagComment}" "${branchToTag}"

    # then push tag
    LANG=en_US git push -f origin "${tagName}"
  done
}
