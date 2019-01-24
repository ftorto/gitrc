#!/bin/bash

# GIT CHECK BRANCH
# check branch against some rules

GREEN="\033[32m"
RED="\033[31m"
YELLOW="\033[33m"
OFF="\033[0m"

currentBranch=$(git rev-parse --abbrev-ref HEAD)
currentBranch=${1:-${currentBranch}}

branchNumber=$(echo ${currentBranch} | sed 's@.*/@@')
echo "Working on branch ${currentBranch}"

baseBranch=$(git merge-base develop ${currentBranch})
baseBranch=${baseBranch:0:7}

commitsCountInBranch=$(git log --oneline develop..${currentBranch} | wc -l)
echo -e "${GREEN}[INFO]${OFF} Found ${GREEN}${commitsCountInBranch}${OFF} commits in branch (from ${baseBranch})"

commitsWithoutRef=$(git log --oneline develop..${currentBranch} --invert-grep --grep "^art #${branchNumber}" | wc -l)
if test ${commitsWithoutRef} -ne 0
then
  echo -e "${RED}[ERR]${OFF} Found ${RED}${commitsWithoutRef}${OFF} commits without 'art #${branchNumber}' in their comments:"
  git log --oneline develop..${currentBranch} --invert-grep --grep "^art #${branchNumber}" | sed 's/^/    /'
fi

if test $(git log --oneline develop..${currentBranch} --grep "^Changelog: \(...\)" | wc -l) -eq 0
then
  echo -e "${YELLOW}[WARN]${OFF} Changelog seems missing in ${currentBranch}"
fi

if test $(git log --oneline develop..${currentBranch} --grep "^Changelog: \(...\)" | wc -l) -eq 1
then
  changelogCommit=$(git log develop..${currentBranch} --grep "^Changelog: \(...\)" --format=format:"%h")
  echo -e "${GREEN}[INFO]${OFF} Found Changelog for ${currentBranch} at ${GREEN}${changelogCommit}${OFF}"
fi

commitsWithChangelog=$(git log --oneline develop..${currentBranch} --grep "^Changelog: \(...\)" | wc -l)
if test ${commitsWithChangelog} -gt 1
then
  echo -e "${YELLOW}[WARN]${OFF} Found ${RED}${commitsWithChangelog}${OFF} changelogs in ${currentBranch}"
  git log --oneline develop..${currentBranch} --grep "^Changelog: \(...\)" | sed 's/^/    /'
fi