#!/bin/bash


while [[ $# -gt 0 ]]
do
   key="$1"

   case ${key} in
      --all)
         changeAllCommitsToMine
         ;;
      --wrong)
         changeWrongFtortoInfo
         ;;
      --sign)
         RemoveSign
         ;;
      -h|--help)
         echo "$0 [options]"
         echo "-h|--help       : This help"
         echo "--all           : Change all commits to ftorto and dev.torto@gmail.com"
         echo "--wrong         : Change author and committer having 'ftorto' to ftorto and dev.torto@gmail.com"
         echo "--sign          : Remove 'Signed-off-by' of commits committed by dev.torto@gmail.com"
         exit 0;
         ;;
      *)
         # Unknown option
         echo -e "--> Option [$1] ignored !"
         ;;
   esac
   shift
done


function changeAllCommitsToMine(){

git filter-branch -f --env-filter '

CORRECT_NAME="ftorto"
CORRECT_EMAIL="dev.torto@gmail.com"

export GIT_COMMITTER_NAME="$CORRECT_NAME"
export GIT_COMMITTER_EMAIL="$CORRECT_EMAIL"
export GIT_AUTHOR_NAME="$CORRECT_NAME"
export GIT_AUTHOR_EMAIL="$CORRECT_EMAIL"

' --tag-name-filter cat -- --branches --tags
}


function changeWrongFtortoInfo(){

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
}



function RemoveSign(){

git filter-branch --msg-filter '

CORRECT_EMAIL="dev.torto@gmail.com"

if [ "$GIT_COMMITTER_EMAIL" = "$CORRECT_EMAIL" ]
then
  sed /^Signed-off-by:/d
fi
'
}
