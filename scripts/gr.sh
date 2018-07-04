#!/bin/bash

USAGE(){
    echo "Apply a command to any sub directory that is a git workspace (contains `.git` folder)"
    echo "gr [options] [--] [command]"
    echo
    echo "-h|--help                : show this help"
    echo "-m|--match <pattern>     : filter on git repository starting with <pattern>"
    echo "-M|--not-match <pattern> : filter on git repository not starting with <pattern>"
    echo "-p|--parallel            : execute the requested commands to all repositories at the same time"
    echo "--file <file>            : use <file> as script to call within each git worksapce"
    exit 0
}

rootpath=$(pwd)/

while test $# -gt 0 
do
    key="$1"

    case ${key} in
        -h|--help)
            USAGE
            break
            ;;
        -m|--match)
            match=$2
            shift
            ;;
        -p|--parallel)
            parallel=true
            ;;
        -M|--not-match)
            notmatch=$2
            shift
            ;;
        --)
            shift
            cmd="$*"
            break
            ;;
        --file)
            cmd_file=$2
            # exists and is not empty
            test -e ${cmd_file} -a -s ${cmd_file} || exit 2
            shift
            break
            ;;
        *)
            cmd="$*"
            break
        ;;
    esac
    shift
done


# Write content to the script if script not provided
if test ! -e "${cmd_file}"
then
    cmd_file=$(mktemp /tmp/git-recurs.XXXXX)
    chmod +x ${cmd_file}
    echo "#!/bin/bash
# PARALLEL_MODE:0 <-- set to 1 to activate the parallelism 
REPO_NAME=\$(basename \$(pwd)) # basename of the repository
BRANCH=\$(LANG=en_US git rev-parse --abbrev-ref HEAD) # Current git branch

hr() {
  local start=$'\e(0' end=$'\e(B' line='qqqqqqqqqqqqqqqq'; local cols=\${COLUMNS:-\$(tput cols)}; while ((\${#line} < cols)); do line+="\$line"; done; printf '%s%s%s\n' "\$start" "\${line:0:cols}" "\$end"
}

[[ \$# -eq 0 ]] && hr && echo -e \"\033[2;37m\$(dirname \$(pwd))/\033[1;32m\$REPO_NAME\033[0m\"

# Uncomment to skip this script if REPO_NAME contains <pattern>
# [[ \$REPO_NAME = *\"pattern\"* ]] && echo 'skip repo!' && exit 0
# Uncomment to skip this script if BRANCH doesn't contain pattern <pattern>
# [[ \$BRANCH != *\"pattern\"* ]] && echo 'skip branch!' && exit 0

#########################################################################
# Please write the script to apply to each GIT repository below
#########################################################################

$cmd"> ${cmd_file}
    if hash vim >/dev/null 2>&1
    then
        # Use vi if installed
        test -z "$cmd" && vi + -c "startinsert!" ${cmd_file}
    else
        # use default editor otherwise
        test -z "$cmd" && ${EDITOR} ${cmd_file}
    fi
fi

# Trigger parallel mode if `-p` is found as argument
# If you omit to specify `-p`, you have another chance to do it by setting the flag directly in the script
test "$parallel" && sed -i 's/PARALLEL_MODE:0/PARALLEL_MODE:1/' ${cmd_file}

for d in `find . -name .git | sed 's@./@@; s@/.git@@'`
do
    # Filter
    test ! -z $match && [[ $d != *"$match"* ]] && continue
    test ! -z $notmatch && [[ $d = *"$notmatch"* ]] && continue

    # Apply command
    pushd $d > /dev/null;
    
    if grep "PARALLEL_MODE = 1" ${cmd_file} > /dev/null 2>&1
    then 
        ${cmd_file} parallel &
    else 
        ${cmd_file}
    fi
    
    popd > /dev/null;
done
wait
echo "script applied is located here : ${cmd_file}"
