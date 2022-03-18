#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

d=.dir_colors
test -r $d && eval "$(dircolors $d)"

test -r ~/.dir_colors && eval $(dircolors ~/.dir_colors)

. $HOME/.bash_alias

PS1='[\u@\h \W]\$ '

. "$HOME/.cargo/env"

eval "$(zoxide init bash)"
