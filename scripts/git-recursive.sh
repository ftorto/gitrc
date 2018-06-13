#!/bin/bash

USAGE(){
    echo "gr [options] [--] [command]"
    echo
    echo "-m|--match <pattern> : filter on git repository starting with <pattern>"
    echo "-M|--not-match <pattern> : filter on git repository not starting with <pattern>"
    echo "-e|--edit : open vim to enter your commands as a script"
    echo "-m|--match <pattern> : filter on git repository starting with <pattern>"
    echo "-m|--match <pattern> : filter on git repository starting with <pattern>"
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
    cmd_file=$(mktemp /tmp/gr.XXXXX)
    chmod +x ${cmd_file}
    echo "#!/bin/bash
# Set the following line to 1 to trigger the parallelism (keep the comment)
# PARALLEL_MODE = 0

# Use the following variable to refer to the basename of the repository
REPO_NAME=\$(basename \$(pwd))
# Current git branch
BRANCH=\$(LANG=en_US git rev-parse --abbrev-ref HEAD)

if [[ \$# -eq 0 ]]
then
    printf '%*s\n' \"\${COLUMNS:-\$(tput cols)}\" '' | tr ' ' _
    echo -e \"\033[2;37m\$(dirname \$(pwd))/\033[1;32m\$REPO_NAME\033[0m\"
fi
# Uncomment to skip this script if REPO_NAME contains <pattern>
# [[ \$REPO_NAME = *\"pattern\"* ]] && echo 'skip repo!' && exit 0
# Uncomment to skip this script if BRANCH doesn't contain pattern <pattern>
# [[ \$BRANCH != *\"pattern\"* ]] && echo 'skip branch!' && exit 0

#########################################################################
# Please write the script to apply to each GIT repository below
#########################################################################

$cmd"> ${cmd_file}
    test -z "$cmd" && vim + -c "startinsert!" ${cmd_file}
fi

test "$parallel" && sed -i 's/PARALLEL_MODE = 0/PARALLEL_MODE = 1/' ${cmd_file}

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
echo "script applied is located here : ${cmd_file}"
