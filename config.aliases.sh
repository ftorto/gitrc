#!/bin/bash

test -e config.env && source config.env

# GIT_GLOBAL_CONFIG allow to specify if config shall be applied globally or locally
[[ ${GIT_GLOBAL_CONFIG} ]] && GIT_GLOBAL_CONFIG_SWITCH="--global"

# SHORTCUTS
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.psuh 'push'
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.st '!LANG=en_US git status -sb'
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.f '!LANG=en_US git fetch --all --prune --tags --recurse-submodules --jobs=4'
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.co '!LANG=en_US git checkout'
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.cob '!LANG=en_US git checkout -b'
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.commit '!LANG=en_US git commit ${SIGN_SWITCH}'
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.ci '!LANG=en_US git commit ${SIGN_SWITCH}'
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.cim '!LANG=en_US git commit ${SIGN_SWITCH} -m'
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.cp '!LANG=en_US git cherry-pick'
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.br '!LANG=en_US git branch -vv'
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.amend '!LANG=en_US git commit --amend'
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.pop '!LANG=en_US git stash pop'
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.clean 'clean -xdf'
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.rc 'rebase --continue'
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.ra 'rebase --abort'
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.bis 'bisect start'
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.good 'bisect good'
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.bad 'bisect bad'
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.bir 'bisect reset'

git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.mysha1 '!LANG=en_US git rev-parse --short HEAD'
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.mybranch '!LANG=en_US git rev-parse --abbrev-ref HEAD'

# DIFF / MERGE
if test ${GIT_GRAPHICAL} -eq 1
then
  # Use MELD as diff
  git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.dd 'difftool'
  git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.d 'difftool --dir-diff'
  git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.dc 'difftool --dir-diff --cached'
  
fi
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.diffc 'diff --cached'
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.ma 'merge --abort'

# List the impacted files
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.impacted 'diff --name-only'

# UNDO
# Set the HEAD to the specified commit and set all changes to stage
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.uncommit '!LANG=en_US git reset --soft'
# Undo add and keep changes in local (not staged)
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.unadd '!LANG=en_US git reset HEAD'

# LOG
# Log One line Truncated
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.lgf '!LANG=en_US git log --graph --format=format:"%C(bold blue)%h%Creset %C(bold green)%>(8,trunc)%ar%Creset%C(dim yellow)%G?%Creset %C(dim white)%<(8,mtrunc)%an%Creset %C(auto)%D%Creset %C(white)%<(30,trunc)%s%Creset" --all --patience'
# Log One line filtered 
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.ll '!LANG=en_US git log --graph --format=format:"%C(bold blue)%h%Creset %C(bold green)%>(8,trunc)%ar%Creset%C(dim yellow)%G?%Creset %C(dim white)%<(8,mtrunc)%an%Creset %C(auto)%D%Creset %C(white)%s%Creset" --patience'
# Log One line 
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.lg '!LANG=en_US git ll --all'
# Log One line with grep on comment
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.lgg '!LANG=en_US git ll --all --grep'

# Log only important commits One line
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.l '!LANG=en_US git lg --simplify-by-decoration'

# Log verbose
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.lll '!LANG=en_US git log --color=auto --graph --format=format:"%C(bold blue)%h%Creset %C(auto)%D%Creset%n""   %C(dim white)Author    %C(green)%aN <%aE>%Creset %C(bold cyan)%ai%Creset %C(bold green)(%ar)%Creset%n""   %C(dim white)Committer %C(dim white)%cN <%cE>%Creset %ci (%cr)%Creset %n""   Sign      %C(dim white)%G? %GS %GK %Creset %n""%C(white)%s%n%b%Creset "'
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.lgl '!LANG=en_US git lll --all'
# Log verbose with grep on comment
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.lllg '!LANG=en_US git log --color=auto --graph --format=format:"%C(bold blue)%h%Creset %C(auto)%D%Creset%n""   %C(dim white)Author    %C(green)%aN <%aE>%Creset %C(bold cyan)%ai%Creset %C(bold green)(%ar)%Creset%n""   %C(dim white)Committer %C(dim white)%cN <%cE>%Creset %ci (%cr)%Creset %n""   Sign      %C(dim white)%G? %GS %GK %Creset %n""%C(white)%s%n%b%Creset " --all --grep'

# TESTS
# Display current graph to be used in documents/presentation
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.ld '!LANG=en_US git log --graph --format=format:"%C(bold blue)%h%Creset%C(auto)% d%Creset" --all --patience'
# Commit a file named test_commit.txt containing the current date
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.tci '!date > test_commit.txt;LANG=en_US git add test_commit.txt;LANG=en_US git commit -m "Test commit `date`"'
# Create a dummy commit
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.tcie '!LANG=en_US git commit --allow-empty -m "Test commit `date`"'

#DAEMON
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.daemonize '!echo "Starting daemon on /home/${USER}/SCM/"; LANG=en_US git daemon --base-path=/home/${USER}/SCM/ --export-all --reuseaddr --informative-errors --verbose'

#Orphan display
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.orphan '!LANG=en_US git ll $(git reflog | cut -c1-7)'
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.orphanlist '!LANG=en_US git reflog | cut -c1-7'
