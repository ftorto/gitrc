#!/bin/bash

# Autocomplete
source ${GITRC_PATH}/scripts/git-completion.bash
source ${GITRC_PATH}/scripts/git-flow-completion.bash
__git_complete g _git
__git_complete gti _git
__git_complete qg _git
__git_complete gf _git_flow

# Prompt
source ${GITRC_PATH}/git_ps1.sh

# git in English
alias git='LANGUAGE=en_US.UTF-8 git'

# Common misspell
alias gti='git'
alias gl='git l'
alias gll='git ll'
alias glll='git lll'
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

# git recursive mode
# Apply a command to all sub git directories
gr() {
  rootpath=$(pwd)/
  [[ $# -eq 0 ]] && multimode=1
  while [[ $# -gt 0 ]]
  do
    key="$1"

    case ${key} in
      -h|--help)
        echo "gr -[hmM] [--] command"
        return 0
        ;;
      -m|--match|-f|--filter)
        match=$2
        shift
        ;;
      -M|--not-match)
        notmatch=$2
        shift
        ;;
      --)
        shift
        cmd="$*"
        break
        ;;
      *)
        cmd="$*"
        break
        ;;
    esac
    shift
  done
  

  if [ ! -z "$multimode" ]
  then
    echo "Multiline (Add empty line to end the input)"
    cmd=""
    while read line
    do
      # Break if the line is empty
      [ -z "$line" ] && break
      cmd+="$line;"
    done
  fi

  for d in `find -name .git | sed 's@./@@; s@/.git@@'`
  do

    if test ! -z $match
    then
      [[ $d != *"$match"* ]] && continue
    fi

    if test ! -z $notmatch
    then
      [[ $d = *"$notmatch"* ]] && continue
    fi

    # Separator
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' _

    # Path
    echo -e "\033[2;37m${rootpath}\033[1;32m$d\033[0m"

    # Apply command
    pushd $d > /dev/null;
    eval $cmd
    popd > /dev/null;
  done
}

# Checkout a branch with fallbacks on sub git repositories
cobr() {
  default_branches="develop master"

  rootpath=$(pwd)/

  branches_order=$*
  if [ $# -eq 0 ]; then
    echo "Need to provide at least 1 branch"
  else
    # Adding default branches at the end
    branches_order="${branches_order} ${default_branches}"

    for d in `find -name .git | sed 's@./@@; s@/.git@@'`
    do
      # Apply command
      pushd $d > /dev/null;

      for b in ${branches_order}
      do
        git checkout $b > /dev/null 2>&1
        if [ $? = 0 ]
        then
          printf "%20s set to %s\n" $d $b
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
    git rev-list --all | xargs git grep --threads 4 --color $1
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

  for d in `find -maxdepth 2 -name .git | sed 's@./@@; s@/.git@@'`
  do
    pushd $d > /dev/null;

    # -s to sign commit
    LANG=en_US git tag -f -as ${tagName} -m "${tagComment}" ${branchToTag}

    # then push tag
    LANG=en_US git push -f origin ${tagName}
  done
}

# Tag the end of a sprint
# Specific
function tag_sprint {
  tag_subgit "sprint$1" "Fin sprint sprint$1" "master"
}
