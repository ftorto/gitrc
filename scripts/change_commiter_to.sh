#!/bin/bash

git filter-branch -f --env-filter '

OLD_COMMITTER_EMAIL="dev.ftorto@gmail.com"
OLD_AUTHOR_EMAIL="dev.ftorto@gmail.com"
CORRECT_NAME="ftorto"
CORRECT_EMAIL="dev.torto@gmail.com"

if [ "$GIT_COMMITTER_EMAIL" = "$OLD_COMMITTER_EMAIL" ]
then
    export GIT_COMMITTER_NAME="$CORRECT_NAME"
    export GIT_COMMITTER_EMAIL="$CORRECT_EMAIL"
fi

if [ "$GIT_AUTHOR_EMAIL" = "$OLD_AUTHOR_EMAIL" ]
then
    export GIT_AUTHOR_NAME="$CORRECT_NAME"
    export GIT_AUTHOR_EMAIL="$CORRECT_EMAIL"
fi

' --tag-name-filter cat -- --branches --tags 
