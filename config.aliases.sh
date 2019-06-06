#!/bin/bash

test -e config.env && source config.env

export LANG=en_US

# GIT_GLOBAL_CONFIG allow to specify if config shall be applied globally or locally
[[ ${GIT_GLOBAL_CONFIG} ]] && GIT_GLOBAL_CONFIG_SWITCH="--global"

# SHORTCUTS
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.psuh 'push'
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.st 'status -sb'
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.f 'fetch --all --prune --tags --recurse-submodules --jobs=4'
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.co 'checkout'
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.cob 'checkout -b'
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.ci 'commit'
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.cim 'commit -m'
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.cp 'cherry-pick'
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.br 'branch -vv'
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.amend 'commit --amend'
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.pop 'stash pop'
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.clean 'clean -xdf'
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.ri 'rebase --preserve-merges -i'
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.rc 'rebase --continue'
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.ra 'rebase --abort'
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.bis 'bisect start'
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.good 'bisect good'
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.bad 'bisect bad'
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.bir 'bisect reset'
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.changes "log --pretty=format:\"%h %cr %cn %Cgreen%s%Creset\" --name-status"

git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.mysha1 'rev-parse --short HEAD'
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.mybranch 'rev-parse --abbrev-ref HEAD'

# DIFF / MERGE
if test "${GIT_GRAPHICAL}" -eq 1
then
  # Use MELD as diff
  git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.dd 'difftool'
  git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.d 'difftool --dir-diff'
  git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.dc 'difftool --dir-diff --cached'
  
fi
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.diffc 'diff --cached'
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.ma 'merge --abort'

git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.base 'merge-base'



# List the impacted files
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.impacted 'diff --name-only'

# UNDO
# Set the HEAD to the specified commit and set all changes to stage
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.uncommit 'reset --soft'
# Undo add and keep changes in local (not staged)
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.unadd 'reset HEAD'

# LOG
# Log One line Truncated
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.lgf 'log --graph --format=format:"%C(bold blue)%h%Creset %C(bold green)%>(8,trunc)%ar%Creset%C(dim yellow)%G?%Creset %C(dim white)%<(8,mtrunc)%an%Creset %C(auto)%D%Creset %C(white)%<(30,trunc)%s%Creset" --all --patience'
# Log One line filtered on current HEAD
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.ll 'log --graph --format=format:"%C(bold blue)%h%Creset %C(bold green)%>(8,trunc)%ar%Creset%C(dim yellow)%G?%Creset %C(dim white)%<(8,mtrunc)%an%Creset %C(auto)%D%Creset %C(white)%s%Creset %C(dim yellow)%N%Creset" --patience'
# Log One line 
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.lg 'll --all'

git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.l2 'log --graph --format=format:"%C(bold blue)%h%Creset %C(bold green)%>(8,trunc)%ar%Creset%C(dim yellow)%G?%Creset %C(dim white)%<(8,mtrunc)%an%Creset %C(auto)%D%Creset %C(white)%<(30,trunc)%s%Creset%n%C(dim white)%b%Creset" --all --patience'

# Log only important commits One line
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.l 'lg --simplify-by-decoration'

# Log verbose
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.lll 'log --graph --format=format:"%C(bold blue)%h%Creset %C(auto)%D%Creset%n""   %C(dim white)Author    %C(green)%aN <%aE>%Creset %C(bold cyan)%ai%Creset %C(bold green)(%ar)%Creset%n""   %C(dim white)Committer %C(dim white)%cN <%cE>%Creset %ci (%cr)%Creset %n""   Sign      %C(dim white)%G? %GS %GK %Creset %n""   Notes     %C(dim yellow)%N%Creset %n""%C(white)%s%n%b%Creset "'
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.lgl 'lll --all'

# TESTS
# Display current graph to be used in documents/presentation
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.ld 'log --graph --format=format:"%C(bold blue)%h%Creset%C(auto)% d%Creset" --all --patience'
# Commit a file named test_commit.txt containing the current date
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.tci '!date > test_commit.txt;LANG=en_US git add test_commit.txt;LANG=en_US git commit -m "Test commit `date`"'
# Create a dummy commit
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.tcie 'commit --allow-empty -m "Test commit `date`"'

#DAEMON
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.daemonize '!echo "Starting daemon on /home/${USER}/SCM/"; LANG=en_US git daemon --base-path=/home/${USER}/SCM/ --export-all --reuseaddr --informative-errors --verbose'

#Orphan display
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.orphan '!LANG=en_US git ll $(git reflog | cut -c1-7)'
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.orphanlist '!LANG=en_US git reflog | cut -c1-7'
