#!/bin/bash

rootpath=$(pwd)/

function USAGE(){
  echo "-u|--update              : Update before display"
  echo "-h|--help                : This page"
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
         exit 0;
         ;;
      *)
         # Unknown option
         echo -e "--> Option [$1] ignored !"
         ;;
   esac
   shift
done

for d in `find . -maxdepth 5 -name .git | sed 's@./@@; s@/.git@@'`
do
   pushd ${rootpath}$d > /dev/null;
   printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' _
   echo -e "\033[0;32m${rootpath}\033[1;34m$d\033[0m"
   test UPDATE == true && LANG=en_US git fetch --all --prune --tags --quiet --jobs=4
   LANG=en_US git branch -vv | egrep '^\* |ahead|behind' | sed -e '
    s/].*/]/;
    s/\([0-9a-f]\{7\}\) [^\[]*/\1 /;
    s/^\(\* [^ ]*\)[ \t]*/\x1b[1;36m\1\x1b[0m /;
    s/\(ahead [0-9]\+\)/\x1b[32m\1\x1b[0m/;
    s/\(gone\)/\x1b[37m\1\x1b[0m/;
    s/\(behind [0-9]\+\)/\x1b[31m\1\x1b[0m/'
   local_branches=$(LANG=en_US git branch |grep -v master| paste --serial --delimiter=\| | sed 's/ //g')

   [ $(LANG=en_US git st|wc -l) -gt 1 ] && LANG=en_US git st
   popd > /dev/null;

done
