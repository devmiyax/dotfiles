# default stuff

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize
shopt -s expand_aliases

#------------------------------------------------------------------------------
# custom
export IS_WORK=0
export IS_SIMPLE_FONT=0

pathadd() {
    if [[ ":$PATH:" != *":$1:"* ]]; then
        PATH="${PATH:+"$PATH:"}$1"
    fi
}
pathadd "/home/${USER}/bin/"

function welcome() {
    local upSeconds="$(/usr/bin/cut -d. -f1 /proc/uptime)"
    local secs=$((upSeconds%60))
    local mins=$((upSeconds/60%60))
    local hours=$((upSeconds/3600%24))
    local days=$((upSeconds/86400))
    local UPTIME=$(printf "%d days, %02dh%02dm%02ds" "$days" "$hours" "$mins" "$secs")

    # calculate rough CPU and GPU temperatures:
    local cpuTempC
    local cpuTempF
    local gpuTempC
    local gpuTempF
    if [[ -f "/sys/class/thermal/thermal_zone0/temp" ]]; then
        cpuTempC=$(($(cat /sys/class/thermal/thermal_zone0/temp)/1000)) && cpuTempF=$((cpuTempC*9/5+32))
    fi

    local df_out=()
    local line
    while read line; do
        df_out+=("$line")
    done < <(df -h /)

    local rst="$(tput sgr0)"
    local fgblk="${rst}$(tput setaf 0)" # Black - Regular
    local fgred="${rst}$(tput setaf 1)" # Red
    local fggrn="${rst}$(tput setaf 2)" # Green
    local fgylw="${rst}$(tput setaf 3)" # Yellow
    local fgblu="${rst}$(tput setaf 4)" # Blue
    local fgpur="${rst}$(tput setaf 5)" # Purple
    local fgcyn="${rst}$(tput setaf 6)" # Cyan
    local fgwht="${rst}$(tput setaf 7)" # White

    local bld="$(tput bold)"
    local bfgblk="${bld}$(tput setaf 0)"
    local bfgred="${bld}$(tput setaf 1)"
    local bfggrn="${bld}$(tput setaf 2)"
    local bfgylw="${bld}$(tput setaf 3)"
    local bfgblu="${bld}$(tput setaf 4)"
    local bfgpur="${bld}$(tput setaf 5)"
    local bfgcyn="${bld}$(tput setaf 6)"
    local bfgwht="${bld}$(tput setaf 7)"

local logo=(
"                    "
"${fgred}     ___ _       __ "
"${fgred}   /   | |     / /  "
"${fgred}  / /| | | /| / /   "
"${fgred} / ___ | |/ |/ /    "
"${fgred}/_/  |_|__/|__/     "
"${fgred}                    "
"                    "
"                    "
"                    "

)


    local out
    local i
    for i in "${!logo[@]}"; do
        out+="  ${logo[$i]}  "
        case "$i" in
            0)
                out+="${fggrn}$(date +"%A, %e %B %Y, %r")"
                ;;
            1)
                out+="${fggrn}$(uname -srmo)"
                ;;
            3)
                out+="${fgylw}${df_out[0]}"
                ;;
            4)
                out+="${fgwht}${df_out[1]}"
                ;;
            5)
                out+="${fgred}Uptime.............: ${UPTIME}"
                ;;
            6)
                out+="${fgred}Memory.............: $(grep MemFree /proc/meminfo | awk {'print $2'})kB (Free) / $(grep MemTotal /proc/meminfo | awk {'print $2'})kB (Total)"
                ;;
            7)
                out+="${fgred}Running Processes..: $(ps ax | wc -l | tr -d " ")"
                ;;
            8)
                out+="${fgred}IP Address.........: $(ip route get 8.8.8.8 2>/dev/null | awk '{print $NF; exit}')"
                ;;
            9)
                out+="Temperature........: CPU: $cpuTempC°C/$cpuTempF°F "
                ;;
        esac
        out+="\n"
    done
    echo -e "\n$out"
}

welcome

# export TERM=rxvt-256color

#echo " Welcome corporate rat"
#echo "         .~.    "
#echo "         /V\    "
#echo "        // \\\\    "
#echo "       /(   )\    "
#echo "        ^\`~'^    "
#echo


#Other
#=====
# Orange
# PS1='\[\e[1;35m\]\u@\h\[\e[m\] \[\e[1;34m\]\w \[\e[1;37m\]'

# Purple
PS1="\[\033[38;5;215m\]\u@\h \[$(tput sgr0)\]\[\033[38;5;12m\]\w \[$(tput sgr0)\]"

# Run ssh agent only once, ignore gnome-keyring
if ! pgrep -u "$USER" -f -x "^ssh-agent$" > /dev/null; then
    echo "starting ssh agent"
    ssh-agent > ~/.ssh-agent-thing
    eval "$(<~/.ssh-agent-thing)" /dev/null
fi
# if [[ "$SSH_AGENT_PID" == "" ]]; then
if [ -f ~/.ssh-agent-thing ]; then
    eval "$(<~/.ssh-agent-thing)" > /dev/null
fi

alias ls="ls --color"
alias l="ls -alh"
alias ll="ls -alh"
alias lls="ls -lh --color"
alias cd..="cd .."
alias lsf="ls -al | grep -i"
alias psf="ps aux -A | grep -i"
alias psmem="ps aux --sort -rss"
alias grepp="grep -Rnsi"
alias c="clear"

alias g="git"

alias makep="prettyfier make"
alias cmakep="prettyfier cmake"
alias ninjap="prettyfier ninja"

# easy find
findfunction() {
  find 2>/dev/null -L -iname "*$1*" ${@:2}
}
alias findn=findfunction
alias findbig="find ./ -type f -print0 | xargs -0 du | sort -n | tail -n 100 | cut -f2 | xargs -I{} du -sh {}"
alias findbigdir="find ./ -maxdepth 1 -type d -print0 | xargs -0 du --max-depth=1 | sort -n | tail -n 50 | tail -n +1 | cut -f2 | xargs -I{} du -sh {}"

alias sc="sudo systemctl"
alias scg="systemctl | grep "
alias sj="sudo journalctl"
alias sl="sudo journalctl"
alias sjf="sudo journalctl -f"
alias slf="sudo journalctl -f"
alias sju="sudo journalctl -u"
alias slu="sudo journalctl -u"
alias sjuf="sudo journalctl -f -u"
alias sluf="sudo journalctl -f -u"
alias sjfu="sudo journalctl -f -u"
alias slfu="sudo journalctl -f -u"

# export http_proxy="http://proxy:9400"
# export https_proxy="https://proxy:9400"
# export ftp_proxy="ftp://proxy:9400"
# export no_proxy="localhost,127.0.0.1,localaddress,.localdomain.com"

# same installation commands
if [ -e /etc/yum.conf ] ; then
    alias ainstall="sudo yum install"
    alias areinstall="sudo yum reinstall"
    alias aremove="sudo yum remove"
    alias asearch="sudo yum search"
    alias ashow="sudo yum info"
    alias alistall="sudo yum installed"
    alias update="sudo yum update"
    alias upgrade="sudo yum update"
fi
if [ -e /etc/pacman.conf ] ; then
    alias pacman="pacman --color always"
    alias ainstall="sudo pacman --color always -S"
    alias areinstall="sudo pacman --color always -S"
    alias aremove="sudo pacman --color always -R"
    alias asearch="pacsearch"
    alias ashow="pacman --color always -Si"
    alias ashowfiles="pacman --color always -Qlq"
    alias ashowlocal="pacman --color always -Qi"
    alias alistall="pacman --color always -Q"
    alias alistallexplicit="pacman --color always -Qqe"
    alias update="sudo pacman --color always -Qu"
    alias upgrade="sudo pacman --color always -Syyu"
fi
if [ -d /etc/apt ] ; then
    alias ainstall="sudo apt-get install"
    alias areinstall="sudo apt-get install --reinstall"
    alias aremove="sudo apt-get --purge remove"
    alias asearch="sudo apt-cache search"
    alias ashow="sudo apt-cache show"
    alias alistall="sudo apt --installed list"
    alias update="sudo apt-get update"
    alias upgrade="sudo apt-get upgrade"
    alias uu="update && upgrade"
fi
if [ -d /mingw32 ] ; then
    alias pacman="pacman --color always"
    alias ainstall="pacman --color always -S"
    alias areinstall="pacman --color always -S"
    alias aremove="pacman --color always -RS"
    alias asearch="pacsearch"
    alias ashow="pacman --color always -Si"
    alias ashowfiles="pacman --color always -Qlq"
    alias ashowlocal="pacman --color always -Qi"
    alias alistall="pacman --color always -Q"
    alias update="pacman -Qu"
    alias upgrade="pacman -Syyu"
fi

# supervisord shortucts
alias sreread="sudo supervisorctl reread"
alias supdate="sudo supervisorctl update"
alias sstatus="sudo supervisorctl status"
alias sstart="sudo supervisorctl start"
alias sstop="sudo supervisorctl stop"
alias srestart="sudo supervisorctl restart"
alias stail="sudo supervisorctl tail"
alias staill="sudo supervisorctl tail -8000"
alias stailf="sudo supervisorctl tail -f"
alias sgogo="sudo supervisorctl reread && sudo supervisorctl update && echo --wait-- && sleep 3 && sudo supervisorctl status"

# git shortcuts
alias gf="git fetch"
alias gfa="git fetch --all"
alias gs="git s"
alias gg="git g"
alias gb="git branch"
alias gd="git dd"
alias gm="git merge"
alias gc="git commit"
alias gu="git u"
alias git-nossl="git -c http.sslVerify=false"
# alias git-amend-now='GIT_COMMITTER_DATE="LC_ALL=en_US.utf8 date -R" git commit --amend --date "LC_ALL=en_US.utf8 date -R"'
alias git-amend-now='export YESTERDAYEVENING=$(LC_ALL=en_US.utf8 date -R) export GIT_COMMITTER_DATE="$YESTERDAYEVENING" ; git commit --date "$YESTERDAYEVENING" --amend ; export GIT_COMMITTER_DATE=""'
alias git-amend-yesterday='export YESTERDAYEVENING=$(LC_ALL=en_US.utf8 date --date="`echo $(( 18 + $RANDOM % 4 ))`:`echo $(( $RANDOM % 59))` yesterday") ; export GIT_COMMITTER_DATE="$YESTERDAYEVENING" ; git commit --date "$YESTERDAYEVENING" --amend ; export GIT_COMMITTER_DATE=""'

alias torrent="transmission-cli -w ~/torrent/ "

#dictionary search
alias look="look"

#eval $(thefuck --alias)
#alias f="fuck"
alias makev="make SHELL='sh -x'"


## set some other defaults ##
alias df="df -hT"
alias du='du -ch'
alias less_="less"
alias less="less -r"
alias grep='grep --color'
alias grep_="grep --color=never"
alias grep="grep --color=always"

alias ..='cd ..'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .....='cd ../../../../'
alias .4='cd ../../../../'
alias .5='cd ../../../../..'


# install  colordiff package :)
alias diff='colordiff'
alias dwdiff='dwdiff -c -L -C3'

#12: Show open ports
alias ports='netstat -tulanp'

#Control WebServer
alias rapache2="sudo service apache2 restart"
alias rsshd="sudo service ssh restart"

alias reveal="nautilus . &"

# for badly configured servers
alias ssh_nopubkey="ssh -o PubkeyAuthentication=no"


## pass options to free ##
alias meminfo='free -m -l -t'

## get top process eating memory
alias psmem='ps auxf | sort -nr -k 4'
alias psmem10='ps auxf | sort -nr -k 4 | head -10'

alias updateycm='cd ~/.vim/bundle/YouCompleteMe && git pull && git pull --recurse-submodules && ./install.py --clang-completer'
alias updateycmall='cd ~/.vim/bundle/YouCompleteMe && git pull && git pull --recurse-submodules && ./install.py --clang-completer --gocode-completer --tern-completer'

## get top process eating cpu ##
alias pscpu='ps auxf | sort -nr -k 3'
alias pscpu10='ps auxf | sort -nr -k 3 | head -10'

## Get server cpu info ##
alias cpuinfo='lscpu'

weather() {
curl -s wttr.in/$1
}


# nice, more readable manual! This is a must
man() {
    env \
    LESS_TERMCAP_mb=$'\e[01;31m' \
    LESS_TERMCAP_md=$'\e[01;38;5;74m' \
    LESS_TERMCAP_me=$'\e[0m' \
    LESS_TERMCAP_se=$'\e[0m' \
    LESS_TERMCAP_so=$'\e[46;30m' \
    LESS_TERMCAP_ue=$'\e[0m' \
    LESS_TERMCAP_us=$'\e[04;38;5;146m' \
    man "$@"
}

# load custom promt and commands
if [ -f "$HOME/.promt" ]; then
  . "$HOME/.promt"
fi

# set vi mode
# http://www.catonmat.net/blog/bash-vi-editing-mode-cheat-sheet/
set -o vi


# bind home and end to ESC+insert on ^ and $
# http://stackoverflow.com/questions/4200800/in-bash-how-do-i-bind-a-function-key-to-a-command
# http://www.gnu.org/software/bash/manual/html_node/Bash-Builtins.html
# Not needed on most system, needed on ubuntu... :(
if [ -f /etc/lsb-release ]; then
    if [ $(grep Ubuntu /etc/lsb-release | wc -l) != "0" ] ; then
        bind -m vi-insert '"\e[1~":"\eI"'
        bind -m vi-insert '"\e[4~":"\eA"'
        bind -m vi '"\e[1~":"^"'
        bind -m vi '"\e[4~":"$"'
    fi
fi
# page up and page down
bind -m vi '"\e[5~":"\e[A"'
bind -m vi-insert '"\e[5~":"\e[A"'
bind -m vi '"\e[6~":"\e[B"'
bind -m vi-insert '"\e[6~":"\e[B"'

fsdevice () {
    SCRIPT_USER=$USER
    MACHINE="NONE"
    MOUNT_POINT="$HOME/device"
    PORT=22
    # shift
    while [[ $# -gt 0 ]] ; do
        key="$1"
        # echo "#processing: $key"
        case $key in
            -u|--user)
                SCRIPT_USER="$2"
                shift # past argument
                ;;
            -m|--mount)
                MOUNT_POINT="$2"
                shift # past argument
                ;;
            -p|--port)
                PORT="$2"
                shift # past argument
                ;;
            *)
                MACHINE=$1
                ;;
        esac
        shift # past argument or value
    done
    if [ $MACHINE = "NONE" ] ; then echo "missing target machine" ; return 1 ; fi
    mkdir -p $MOUNT_POINT 2>/dev/null
    # echo ARGS: $MACHINE , $MOUNT_POINT , $SCRIPT_USER , $PORT
    sudo fusermount -zu $MOUNT_POINT
    sudo sshfs ${SCRIPT_USER}@${MACHINE}:/ -p $PORT $MOUNT_POINT -C -o allow_other
    echo "Mounted ${SCRIPT_USER}@${MACHINE}:/ at $MOUNT_POINT"
}

fsroot () {
  fsdevice -u root $*
}

#------------------------------------------------------------------------------
# select best editor
if hash nvim 2>/dev/null; then
    export EDITOR=nvim
    export SUDO_EDITOR=nvim
    export GIT_EDITOR=nvim
    # fix Ctrl+H for neovim + tmux
    infocmp $TERM | sed 's/kbs=^[hH]/kbs=\\177/' > ~/$TERM.ti ; tic ~/$TERM.ti
    alias vim="nvim"
elif hash vim 2>/dev/null; then
    export EDITOR=vim
    export SUDO_EDITOR=vim
    export GIT_EDITOR=vim
else
    export EDITOR=vi
    export SUDO_EDITOR=vi
    export GIT_EDITOR=vi
    alias vim="vi"
fi

#------------------------------------------------------------------------------
# FZF

# fd - cd to selected directory
fd() {
  local dir
  dir=$(find ${1:-.} -path '*/\.*' -prune \
                  -o -type d -print 2> /dev/null | fzf +m) &&
  cd "$dir"
}
alias fcd="fd"
alias cdf="fd"

# locate
cf() {
  local file

  file="$(locate -Ai -0 $@ | grep -z -vE '~$' | fzf --read0 -0 -1)"

  if [[ -n $file ]]
  then
     if [[ -d $file ]]
     then
        cd -- $file
     else
        cd -- ${file:h}
     fi
  fi
}
alias locatef="cf"

# Modified version where you can press
#   - CTRL-O to open with `open` command,
#   - CTRL-E or Enter key to open with the $EDITOR
#   - anything else, cd to that file
fo() {
  local out file key
  IFS=$'\n' out=$(fzf --query="$1" --exit-0 --expect=ctrl-o,ctrl-e)
  key=$(head -1 <<< "$out")
  file=$(head -2 <<< "$out" | tail -1)
  if [ -n "$file" ]; then
      [ "$key" = ctrl-o ] && open "$file" || [ "$key" = ctrl-e ] && ${EDITOR:-vim} "$file" || cd -- $(dirname "$file")
  fi
}

# cd to file
fff() {
    local file
    file=$(fzf)
    cd -- $(dirname $file)
    echo $file
}
alias fdf="fff"

# fkill - kill process
fkill() {
  local pid
  pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')

  if [ "x$pid" != "x" ]
  then
    echo $pid | xargs kill -${1:-9}
  fi
}

# fbr - checkout git branch
fbrl() {
  local branches branch
  branches=$(git branch -vv) &&
  branch=$(echo "$branches" | fzf +m) &&
  git checkout $(echo "$branch" | awk '{print $1}' | sed "s/.* //")
}

# fbr - checkout git branch (including remote branches)
fbr() {
  local branches branch
  branches=$(git branch --all | grep -v HEAD) &&
  branch=$(echo "$branches" |
           fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

# Setup cdg function
unalias cdg 2> /dev/null
cdg() {
   local dest_dir=$(cat ~/.cdg_paths | sed "/^\s*$/d" | fzf )
   if [[ $dest_dir != '' ]]; then
      cd "$dest_dir"
   fi
}
export -f cdg > /dev/null

alias marks="mark -l"


# [ -f ~/.fzf.bash ] && export HISTCONTROL=ignoreboth:erasedups
# [ -f ~/.fzf.bash ] && export HISTCONTROL=ignoreboth
# export HISTCONTROL=ignoredups:erasedups  # no duplicate entries
export HISTCONTROL=ignoredups
export HISTSIZE=10000                   # big big history
export HISTFILESIZE=10000               # big big history
shopt -s histappend                     # append to history, don't overwrite it
# Save and reload the history after each command finishes
# export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

if [[ -f ~/.fzf.bash ]]; then
    source ~/.fzf.bash
elif [ -d /usr/share/fzf ] ; then
    source /usr/share/fzf/completion.bash
    source /usr/share/fzf/key-bindings.bash
fi
