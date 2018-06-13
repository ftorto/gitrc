#!/usr/bin/env bash

__powerline() {

    # Unicode symbols
    GIT_BRANCH_SYMBOL='⑂'
    GIT_BRANCH_STAGED_SYMBOL='+'
    GIT_BRANCH_CHANGED_SYMBOL='+'
    GIT_NEED_PUSH_SYMBOL='⇡'
    GIT_NEED_PULL_SYMBOL='⇣'

    FG_BLACK="\[$(tput setaf 0)\]"
    FG_RED="\[$(tput setaf 1)\]"
    FG_GREEN="\[$(tput setaf 2)\]"
    FG_YELLOW="\[$(tput setaf 3)\]"
    FG_BLUE="\[$(tput setaf 4)\]"
    FG_MAGENTA="\[$(tput setaf 5)\]"
    FG_CYAN="\[$(tput setaf 6)\]"
    FG_WHITE="\[$(tput setaf 7)\]"
    FG_ORANGE="\[$(tput setaf 9)\]"
    FG_VIOLET="\[$(tput setaf 13)\]"

    BG_BLACK="\[$(tput setab 0)\]"
    BG_RED="\[$(tput setab 1)\]"
    BG_GREEN="\[$(tput setab 2)\]"
    BG_YELLOW="\[$(tput setab 3)\]"
    BG_BLUE="\[$(tput setab 4)\]"
    BG_MAGENTA="\[$(tput setab 5)\]"
    BG_CYAN="\[$(tput setab 6)\]"
    BG_WHITE="\[$(tput setab 7)\]"
    BG_ORANGE="\[$(tput setab 9)\]"
    BG_VIOLET="\[$(tput setab 13)\]"

    DIM="\[$(tput dim)\]"
    REVERSE="\[$(tput rev)\]"
    RESET="\[$(tput sgr0)\]"
    BOLD="\[$(tput bold)\]"
    UNDERLINE="\[$(tput smul)\]"
    BLINK="\[$(tput blink)\]"

    __git_info() {
        [ -x "$(which git)" ] || return    # git not found
        git rev-parse >/dev/null 2>&1 || return    # git repo not found

        local git_eng="env LANG=C git"   # force git output in English to make our work easier
        #read -r gitDir inGitDir inWorkingTree branch <<< $(git rev-parse --absolute-git-dir --is-inside-git-dir --is-inside-work-tree --abbrev-ref HEAD 2>/dev/null)
        gitDir=$($git_eng rev-parse --absolute-git-dir HEAD 2>/dev/null | head -1)
        inGitDir=$($git_eng rev-parse --is-inside-git-dir HEAD 2>/dev/null | head -1)
        inWorkingTree=$($git_eng rev-parse --is-inside-work-tree  HEAD 2>/dev/null | head -1)
        branch=$($git_eng rev-parse  --abbrev-ref HEAD 2>/dev/null | head -1)

        local marks

        if [[ "$inGitDir" == "true" ]]
        then
          printf "${FG_RED}.git "
          return
        fi

        # branch is modified?
        local _git_status=$($git_eng status --porcelain)
        [ -n "$(echo $_git_status)" ] && marks+=" ";
        local nb_staged=$(echo "$_git_status" | grep '^[A-Z]' | wc -l)
        local nb_notstaged=$(echo "$_git_status" | grep '^.[A-Z]' | wc -l)
        local nb_nothandled=$(echo "$_git_status" | grep '^??' | wc -l)
        [ $nb_staged -gt 0 ] && marks+="${BOLD}${FG_GREEN}${nb_staged}${RESET}";
        [ $nb_notstaged -gt 0 ] && marks+="${BOLD}${FG_RED}${nb_notstaged}${RESET}";
        [ $nb_nothandled -gt 0 ] && marks+="${BOLD}${FG_WHITE}${nb_nothandled}${RESET}";

        # how many commits local branch is ahead/behind of remote?
        local stat="$($git_eng status --porcelain --branch | grep '^##' | grep -o '\[.\+\]$')"
        local aheadN="$(echo $stat | grep -o 'ahead [[:digit:]]\+' | grep -o '[[:digit:]]\+')"
        local behindN="$(echo $stat | grep -o 'behind [[:digit:]]\+' | grep -o '[[:digit:]]\+')"
        [ -n "$aheadN$behindN" ] && marks+=" ";
        [ -n "$aheadN" ] && marks+="${FG_GREEN}${GIT_NEED_PUSH_SYMBOL}${aheadN}${RESET}"
        [ -n "$behindN" ] && marks+="${FG_RED}${GIT_NEED_PULL_SYMBOL}${behindN}${RESET}"

        # Detect pending actions
        [ -d "${gitDir}/rebase-merge" ] && marks+="|${BG_ORANGE}${FG_YELLOW}REBASING${RESET}"
        [ -d "${gitDir}/rebase-apply" ] && marks+="|${BG_ORANGE}${FG_YELLOW}REBASING${RESET}"
        [ -f "${gitDir}/MERGE_HEAD" ] && marks+="|${BG_ORANGE}${FG_YELLOW}MERGING${RESET}"
        [ -f "${gitDir}/CHERRY_PICK_HEAD" ] && marks+="|${BG_ORANGE}${FG_YELLOW}CHERRY-PICKING${RESET}"
        [ -f "${gitDir}/REVERT_HEAD" ] && marks+="|${BG_ORANGE}${FG_YELLOW}REVERTING${RESET}"
        [ -f "${gitDir}/BISECT_LOG" ] && marks+="|${BG_ORANGE}${FG_YELLOW}BISECTING${RESET}"

        # print the git branch segment without a trailing newline
        printf "${FG_BLUE}${BOLD}${GIT_BRANCH_SYMBOL} ${branch}${RESET}${marks} "
    }

    ps1() {
        # Check the exit code of the previous command and display different
        # colors in the prompt accordingly.
        prevExitCode=$?
        if [ ${prevExitCode} -eq 0 ]; then
            local BG_EXIT="${RESET}"
        else
            local BG_EXIT="${BG_RED}${prevExitCode}${RESET} "
        fi

        PS1="$(__git_info)${RESET}"
        PS1+="${FG_WHITE}${DIM}\w ${RESET}"
        PS1+="${BG_EXIT}\$ "
    }

    PROMPT_COMMAND=ps1
}

__powerline
unset __powerline
