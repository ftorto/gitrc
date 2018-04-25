#!/bin/bash

git filter-branch --msg-filter '

CORRECT_EMAIL="dev.torto@gmail.com"

if [ "$GIT_COMMITTER_EMAIL" = "$CORRECT_EMAIL" ]
then
  sed /^Signed-off-by:/d
fi
'
