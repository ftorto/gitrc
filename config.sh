#!/bin/bash

# GIT_GLOBAL_CONFIG allow to specify if config shall be applied globally or locally
[[ ${GIT_GLOBAL_CONFIG} ]] && GIT_GLOBAL_CONFIG_SWITCH=" --global "

echo "INF Installing GIT Configuration"
if [[ -e config.env ]]
then
  source config.env
  git config ${GIT_GLOBAL_CONFIG_SWITCH} user.email "${GIT_USER_EMAIL}"

  # AUTH
  git config ${GIT_GLOBAL_CONFIG_SWITCH} user.name "${GIT_USER_NAME}"
  git config ${GIT_GLOBAL_CONFIG_SWITCH} credential.username "${GIT_CRED_NAME:-$GIT_USER_NAME}"
  git config ${GIT_GLOBAL_CONFIG_SWITCH} credential.helper cache
else
  echo "INF Please set up your configuration in config.env file"
fi

# Proxy configuration
#git config http.proxy $PROXY_INFO
#git config https.proxy $PROXY_INFO

# SIGN
SIGN_SWITCH=""
if [[ "${GIT_SIGNING_KEY}" ]]
then
  echo "INF Installing signing key"
  git config ${GIT_GLOBAL_CONFIG_SWITCH} user.signingkey ${GIT_SIGNING_KEY}
  git config ${GIT_GLOBAL_CONFIG_SWITCH} commit.gpgsign true
  # Cache the passphrase for 10m
  sed -i 's/default-cache-ttl.*/default-cache-ttl 600/' ~/.gnupg/gpg-agent.conf 2>/dev/null || echo "default-cache-ttl 600" >> ~/.gnupg/gpg-agent.conf

  SIGN_SWITCH="-s"
  if hash gpg2
  then
    git config ${GIT_GLOBAL_CONFIG_SWITCH} gpg.program gpg2
  else
    hash gpg2 > /dev/null 2>&1 || echo "WAR Please install gpg2 !"
  fi
else
  git config ${GIT_GLOBAL_CONFIG_SWITCH} --unset user.signingkey
  git config ${GIT_GLOBAL_CONFIG_SWITCH} commit.gpgsign false
  echo "WAR No signingKey found !"
fi

# PUSH METHOD
git config ${GIT_GLOBAL_CONFIG_SWITCH} push.default current

# Push tags automatically
git config ${GIT_GLOBAL_CONFIG_SWITCH} push.followTags
git config ${GIT_GLOBAL_CONFIG_SWITCH} core.autocrlf input

# VIZ
# Colorize outputs
git config ${GIT_GLOBAL_CONFIG_SWITCH} color.ui true
# Use VI as default editor
git config ${GIT_GLOBAL_CONFIG_SWITCH} core.editor vi

# SHORTCUTS
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.st '!LANG=en_US git status -sb'
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.f '!LANG=en_US git fetch --all --prune --tags --recurse-submodules'
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.co '!LANG=en_US git checkout'
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.cob '!LANG=en_US git checkout -b '
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.commit "!LANG=en_US git commit ${SIGN_SWITCH}"
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.ci "!LANG=en_US git commit ${SIGN_SWITCH}"
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.cim "!LANG=en_US git commit ${SIGN_SWITCH} -m"
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

# Enable the recording of resolved conflicts, so that identical hunks can be resolved automatically later on
git config ${GIT_GLOBAL_CONFIG_SWITCH} rerere.enabled true

# Always show a diffstat at the end of a merge
git config ${GIT_GLOBAL_CONFIG_SWITCH} merge.stat true

# DIFF / MERGE
if test ${GIT_GRAPHICAL}
then
  git config ${GIT_GLOBAL_CONFIG_SWITCH} diff.tool 'meld'
  git config ${GIT_GLOBAL_CONFIG_SWITCH} merge.tool 'meld'
  # Use MELD as diff
  git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.d 'difftool --dir-diff'
fi
# Compute a better diff (see http://stackoverflow.com/questions/32365271/whats-the-difference-between-git-diff-patience-and-git-diff-histogram/32367597#32367597)
git config ${GIT_GLOBAL_CONFIG_SWITCH} diff.algorithm histogram
# Group diff elements smarter
git config ${GIT_GLOBAL_CONFIG_SWITCH} diff.compactionHeuristic true
# Check for renames/moves
git config ${GIT_GLOBAL_CONFIG_SWITCH} diff.renames true
# List the impacted files
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.impacted 'diff --name-only'
# Tell git diff to use mnemonic prefixes (index, work tree, commit, object) instead of the standard a and b notation
git config ${GIT_GLOBAL_CONFIG_SWITCH} diff.mnemonicprefix true

# UNDO
# Set the HEAD to the specified commit and set all changes to stage
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.uncommit '!LANG=en_US git reset --soft'
# Undo add and keep changes in local (not staged)
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.unadd '!LANG=en_US git reset HEAD'

# LOG
# Log One line filtered
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.lgf '!LANG=en_US git log --graph --format=format:"%C(bold blue)%h%Creset %C(bold green)%>(8,trunc)%ar%Creset%C(dim yellow)%G?%Creset %C(dim white)%<(8,trunc)%an%Creset %C(auto)%D%Creset %C(white)%<(30,trunc)%s%Creset" --all --patience'
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.ll '!LANG=en_US git log --graph --format=format:"%C(bold blue)%h%Creset %C(bold green)%>(8,trunc)%ar%Creset%C(dim yellow)%G?%Creset %C(dim white)%<(8,trunc)%an%Creset %C(auto)%D%Creset %C(white)%s%Creset" --patience'
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.lg '!LANG=en_US git ll --all'

# Log only important commits One line
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.l '!LANG=en_US git lg --simplify-by-decoration'


# Log verbose
git config ${GIT_GLOBAL_CONFIG_SWITCH} alias.lll '!LANG=en_US git log --color=auto --graph --format=format:"%C(bold blue)%h%Creset %C(auto)%D%Creset%n""   %C(dim white)Author    %C(green)%aN <%aE>%Creset %C(bold cyan)%ai%Creset %C(bold green)(%ar)%Creset%n""   %C(dim white)Committer %C(dim white)%cN <%cE>%Creset %ci (%cr)%Creset %n""   Sign      %C(dim white)%G? %GS %GK %Creset %n""%C(white)%s%n%b%Creset " --all'

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
