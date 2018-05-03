#!/bin/bash

# Same goal as `git bisect` but without knowing "what is good" or "what is bad" (no bisect is done but a full parsing)

cmd=$1

for commit in $(git log --oneline --all | cut -c1-7)
do
  git checkout ${commit} > /dev/null 2>&1
  eval $cmd
  if [[ $? -eq 0 ]]
  then
    git tag -f "bng-good-${commit}" > /dev/null 2>&1
    echo "$commit good"
  else
    git tag -f "bng-bad-${commit}" > /dev/null 2>&1
    echo "$commit bad"
  fi
done

echo "Cleanup ?"
echo "use git tag | grep bng- | xargs -i git tag -d {}"
