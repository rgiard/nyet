#!/bin/sh

if [ ! -d "$HOME/.rvm/scripts/rvm" ]; then
	\curl -sSL https://get.rvm.io | bash -s -- --ignore-dotfiles
fi

