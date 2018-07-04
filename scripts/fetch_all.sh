#!/bin/bash

rootpath=$(pwd)/

function USAGE(){
  echo "command -[urh] [HLPATTERN]"
  echo "-u|--update              : Update before display"
  echo "-r|--remotes             : Include remotes"
  echo "-h|--help                : This page"
  echo "HLPATTERN : optional pattern to highlight in results"
}

UPDATE=false
while [[ $# -gt 0 ]]
do
   key="$1"

   case ${key} in
      -h|--help)
         USAGE
         exit 0;
         ;;
      -u|--update)
         UPDATE=true
         ;;
      -r|--remotes)
         INCLUDE_REMOTE="a"
         ;;
      *)
         HLPATTERN=$1
         ;;
   esac
   shift
done

for d in `find . -maxdepth 5 -name .git | sed 's@./@@; s@/.git@@'`
do
   pushd ${rootpath}$d > /dev/null;
   printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' _
   echo -e "\033[0;32m${rootpath}\033[1;34m$d\033[0m"
   test $UPDATE == true && LANG=en_US git fetch --all --prune --tags --quiet --jobs=4
   LANG=en_US git branch -${INCLUDE_REMOTE:-""}vv | egrep -v 'remotes.*(HEAD|develop|master)' | egrep '^\* |ahead|behind|remotes' | sed -e '
    s/].*/]/;
    s/\([0-9a-f]\{7\}\) [^\[]*/\1 /;
    s/^\(\* [^ ]*\)[ \t]*/\x1b[1;36m\1\x1b[0m /;
    s/\(ahead [0-9]\+\)/\x1b[32m\1\x1b[0m/;
    s/\(gone\)/\x1b[37m\1\x1b[0m/;
    s/\(remotes\)/\x1b[36m\1\x1b[0m/;
    s/\(behind [0-9]\+\)/\x1b[31m\1\x1b[0m/' | sed "s/\(${HLPATTERN}\)/\x1b[41;32;1m\1\x1b[0m/;"
   local_branches=$(LANG=en_US git branch |grep -v master| paste --serial --delimiter=\| | sed 's/ //g')

   [ $(LANG=en_US git st|wc -l) -gt 1 ] && LANG=en_US git st
   popd > /dev/null;

done
