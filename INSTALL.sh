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

# Checking minimum git version available
git --version
if ls /etc/apt/sources.list.d/git* > /dev/null
then
    read -p "Install latest git sources (PPA) [Yn] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        sudo apt-add-repository ppa:git-core/ppa && apt-get update && apt-get install git -y
    fi
fi

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


# Creating 'g' and 'qg' shortcuts
rm -rf "${GITRC_PATH:?}/bin"
mkdir "${GITRC_PATH:?}/bin"
ln -s "$(which git)" "${GITRC_PATH:?}/bin/g"
# This one happen when trying to quit an interactive git log but log fit the screen
ln -s "$(which git)" "${GITRC_PATH:?}/bin/qg"

# Creation fetch_all shortcut
ln -s "$(pwd)/scripts/fetch_all.sh" "${GITRC_PATH:?}/bin/fall"

ln -s "$(pwd)/scripts/stamp.sh" "${GITRC_PATH:?}/bin/git-stamp"
ln -s "$(pwd)/scripts/git-checkbr.sh" "${GITRC_PATH:?}/bin/git-checkbr"

# git recursive
ln -s "$(pwd)/scripts/gr.sh" "${GITRC_PATH:?}/bin/gr"

echo "INF Updating personal gitrc to ~/.bashrc"

# Define patterns to identify the .gitrc configuration part
startPattern="### BEGIN .GITRC CONFIGURATION ###"
endPattern="### END .GITRC CONFIGURATION ###"

# Remove previous run
sed -i "/${startPattern}/,/${endPattern}/d" ~/.bashrc

{
    echo "${startPattern}"
    echo "# DO NOT MODIFY THIS PART MANUALLY"
    echo "# Sourcing personal git configuration"
    echo "export GITRC_PATH=${GITRC_PATH}"
    echo "export GPG_TTY=\$(tty)"
    echo "source \"${GITRC_PATH}/gitrc.sh\""
    echo "${endPattern}"
} >> ~/.bashrc
echo "INF Git install completed"
