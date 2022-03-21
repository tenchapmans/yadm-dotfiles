#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# d=.dir_colors
# test -r $d && eval "$(dircolors $d)"

test -r ~/.dir_colors && eval $(dircolors ~/.dir_colors)

. $HOME/.bash_alias

PS1='[\u@\h \W]\$ '

. "$HOME/.cargo/env"

eval "$(zoxide init bash)"

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
