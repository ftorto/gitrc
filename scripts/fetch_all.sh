#!/bin/bash

rootpath=$(pwd)/

function USAGE(){
    echo "command [options] [HLPATTERN]"
    echo
    echo "Options"
    echo "-u|--update              : Update before display"
    echo "-r|--remotes             : Include remotes"
    echo "-c|--current             : Show the current branch even if there is no change"
    echo "-a|--all                 : Show repo even if there is no change"
    echo "-h|--help                : This page"
    echo
    echo "HLPATTERN : optional pattern to highlight in results"
}

hr() {
  local start=$'\e(0' end=$'\e(B' line='qqqqqqqqqqqqqqqq'
  local cols=${COLUMNS:-$(tput cols)}
  while ((${#line} < cols)); do line+="$line"; done
  printf '%s%s%s\n' "$start" "${line:0:cols}" "$end"
}

UPDATE=false
SHOW_CURRENT_BRANCH='remotes'
while [[ $# -gt 0 ]]
do
    key="$1"
    
    case ${key} in
        -h|--help)
            USAGE
            exit 0
        ;;
        -u|--update)
            UPDATE=true
        ;;
        -r|--remotes)
            INCLUDE_REMOTE="a"
        ;;
        -c|--current)
            SHOW_CURRENT_BRANCH='^\* '
        ;;
        -a|--all)
            SHOW_ALL=1
            INCLUDE_REMOTE="a"
            SHOW_CURRENT_BRANCH='^\* '
        ;;
        *)
            HLPATTERN=$1
        ;;
    esac
    shift
done


_title(){
    rootpath=$1
    d=$2
    hr
    echo -e "\033[0;32m${rootpath}\033[1;34m$d\033[0m"
    
}

for d in `find . -maxdepth 5 -name .git 2>/dev/null | sed 's@./@@; s@/.git@@'`
do
    pushd ${rootpath}$d > /dev/null;
    
    # Get information
    r_branches=$(LANG=en_US git branch -${INCLUDE_REMOTE:-""}vv 2>/dev/null | egrep -v 'remotes.*(HEAD|develop|master)' | egrep "${SHOW_CURRENT_BRANCH}|ahead|behind|remotes|${HLPATTERN:-ahead}")
    r_modified=$(git status --porcelain 2>/dev/null|wc -l)
    
    # Title
    if test ! -z "$r_branches" -o "$r_modified" -gt 0 -o ! -z "$SHOW_ALL"
    then
        _title $rootpath $d
        
        # Update
        test $UPDATE == true && git fetch --all --prune --tags --quiet --jobs=4
        
        # Show branches status
        if test ! -z "$r_branches"
        then
            echo "$r_branches" | sed -e '
            s/].*/]/;
            s/\([0-9a-f]\{7\}\) [^\[]*/\1 /;
            s/^\(\* [^ ]*\)[ \t]*/\x1b[1;36m\1\x1b[0m /;
            s/\(ahead [0-9]\+\)/\x1b[32m\1\x1b[0m/;
            s/\(gone\)/\x1b[37m\1\x1b[0m/;
            s/\(remotes\)/\x1b[36m\1\x1b[0m/;
            s/\(behind [0-9]\+\)/\x1b[31m\1\x1b[0m/' | sed "s/\(${HLPATTERN}\)/\x1b[41;32;1m\1\x1b[0m/;"
        fi
        # Show git status
        [ $(git status --porcelain | wc -l) -gt 0 ] && LANG=en_US git status -sb
        
    fi
    popd > /dev/null;
    
done
