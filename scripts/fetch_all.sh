#!/bin/bash

rootpath=$(pwd)/

function USAGE(){
  echo "-v|--verbose             : Verbose mode"
  echo "-h|--help                : This page"
}

verbose=0
while [[ $# -gt 0 ]]
do
   key="$1"

   case ${key} in
      -v|--verbose)
         verbose=1
         ;;
      -h|--help)
         USAGE
         exit 0;
         ;;
      *)
         # Unknown option
         echo -e "--> Option [$1] ignored !"
         ;;
   esac
   shift
done

for d in `find -name .git | sed 's@./@@; s@/.git@@'`
do
   pushd ${rootpath}$d > /dev/null;
   printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' _
   echo -e "\033[0;32m${rootpath}\033[1;34m$d\033[0m"
   LANG=en_US git fetch --all --prune --tags --quiet --jobs=4
   #LANG=en_US git branch -vv | egrep --color=always '^\* |ahead|behind'
   LANG=en_US git branch -vv | sed -e '
    s/].*/]/;
    s/\([0-9a-f]\{7\}\) [^\[]*/\1 /;
    s/^\(\* [^ ]*\)/\x1b[1;36m\1\x1b[0m/;
    s/\(ahead [0-9]\+\)/\x1b[32m\1\x1b[0m/;
    s/\(behind [0-9]\+\)/\x1b[31m\1\x1b[0m/'
   local_branches=$(LANG=en_US git branch |grep -v master| paste --serial --delimiter=\| | sed 's/ //g')
   [ $verbose -gt 0 ] && LANG=en_US git branch --remotes | egrep -v "${local_branches:-master}|master"
   [ $(LANG=en_US git st|wc -l) -gt 1 ] && LANG=en_US git st
   popd > /dev/null;

done
