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
  # cache passwords for 31 days
  git config ${GIT_GLOBAL_CONFIG_SWITCH} credential.helper 'cache --timeout=2678400'
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
  # Cache the passphrase for 1d
  sed -i 's/default-cache-ttl.*/default-cache-ttl 86400/' ~/.gnupg/gpg-agent.conf 2>/dev/null || echo "default-cache-ttl 86400" >> ~/.gnupg/gpg-agent.conf

  SIGN_SWITCH="-s"
  if hash gpg2 > /dev/null 2>&1
  then
    git config ${GIT_GLOBAL_CONFIG_SWITCH} gpg.program gpg2
  else
    echo "WAR Please install gpg2 !"
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

# Enable the recording of resolved conflicts, so that identical hunks can be resolved automatically later on
git config ${GIT_GLOBAL_CONFIG_SWITCH} rerere.enabled true

# Always show a diffstat at the end of a merge
git config ${GIT_GLOBAL_CONFIG_SWITCH} merge.stat true

# DIFF / MERGE
if test ${GIT_GRAPHICAL}
then
  git config ${GIT_GLOBAL_CONFIG_SWITCH} diff.tool 'meld'
  git config ${GIT_GLOBAL_CONFIG_SWITCH} merge.tool 'meld'
fi
# Compute a better diff (see http://stackoverflow.com/questions/32365271/whats-the-difference-between-git-diff-patience-and-git-diff-histogram/32367597#32367597)
git config ${GIT_GLOBAL_CONFIG_SWITCH} diff.algorithm histogram
# Group diff elements smarter
git config ${GIT_GLOBAL_CONFIG_SWITCH} diff.compactionHeuristic true
# Check for renames/moves
git config ${GIT_GLOBAL_CONFIG_SWITCH} diff.renames true

