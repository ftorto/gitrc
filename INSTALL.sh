#!/bin/bash
# Called only the first time

test -e config.env && source config.env || echo "Fill in config.env file first" || exit 1

# Minimum variables to be set
exit_flag=0
for varname in "GIT_USER_EMAIL" "GIT_USER_NAME" "GIT_CRED_DEFAULT_NAME"
do
    if test -z "${!varname}"
    then
        echo "Please set up ${varname} in config.env file"
        exit_flag=1
    fi
done
test ${exit_flag} -eq 1 && exit 1

# All configuration will be global
export GIT_GLOBAL_CONFIG=1

./upgrade_git.sh

GITRC_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export GITRC_PATH

# git config stuff
./config.sh
./config.aliases.sh

# Trying to update git-completion.bash
rm -f scripts/git-completion.bash.bkp > /dev/null 2>&1
if wget -O scripts/git-completion.bash.new "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash" > /dev/null 2>&1
then
    mv scripts/git-completion.bash scripts/git-completion.bash.bkp
    mv scripts/git-completion.bash.new scripts/git-completion.bash
    chmod +x scripts/git-completion.bash
else
    echo "WAR Impossible to get fresh git-completion.bash. Using old one"
    rm -f scripts/git-completion.bash.new
fi
# Trying to update git-flow-completion.bash
rm -f scripts/git-flow-completion.bash.bkp > /dev/null 2>&1
if wget -O scripts/git-flow-completion.bash.new "https://raw.githubusercontent.com/bobthecow/git-flow-completion/master/git-flow-completion.bash" > /dev/null 2>&1
then
    mv scripts/git-flow-completion.bash scripts/git-flow-completion.bash.bkp
    mv scripts/git-flow-completion.bash.new scripts/git-flow-completion.bash
    chmod +x scripts/git-flow-completion.bash
else
    echo "WAR Impossible to get fresh git-flow-completion.bash. Using old one"
    rm -f scripts/git-flow-completion.bash.new
fi

## BIN setup
# Cleaning
rm -rf "${GITRC_PATH:?}/bin"
mkdir "${GITRC_PATH:?}/bin"
# Creating 'g' and 'qg' shortcuts
ln -s "$(which git)" "${GITRC_PATH:?}/bin/g"
# This one happen when trying to quit an interactive git log but log fit the screen
ln -s "$(which git)" "${GITRC_PATH:?}/bin/qg"
ln -s "${GITRC_PATH:?}/scripts/fetch_all.sh" "${GITRC_PATH:?}/bin/fall"
ln -s "${GITRC_PATH:?}/scripts/stamp.sh" "${GITRC_PATH:?}/bin/git-stamp"
ln -s "${GITRC_PATH:?}/scripts/git-chkbr.sh" "${GITRC_PATH:?}/bin/git-chkbr"
ln -s "${GITRC_PATH:?}/scripts/gr.sh" "${GITRC_PATH:?}/bin/gr"

function source_gitrc(){
    profile_file=${1:-"~/.bashrc"}
    echo "INF Updating personal gitrc to  ${profile_file}"

    # Define patterns to identify the .gitrc configuration part
    startPattern="### BEGIN .GITRC CONFIGURATION ###"
    endPattern="### END .GITRC CONFIGURATION ###"

    sed -i "/${startPattern}/,/${endPattern}/d" ${profile_file}
    {
        echo "${startPattern}"
        echo "# DO NOT MODIFY THIS PART MANUALLY"
        echo "# Sourcing personal git configuration"
        echo "export GITRC_PATH=${GITRC_PATH}"
        echo "source \"${GITRC_PATH}/gitrc.sh\""
        echo "${endPattern}"
    } >> ${profile_file}
}

profile_rc=~/.bashrc
[[ "$SHELL" =~ zsh ]] && profile_rc=~/.zshrc
source_gitrc ${profile_rc}

echo "INF Git install completed"
