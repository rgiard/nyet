#!/usr/bin/env bash

. environment.sh

if [ ! -d "$HOME/.rvm" ]; then
	\curl -sSL https://get.rvm.io | bash -s -- --ignore-dotfiles
else
	echo "RVM already installed"
fi

. $HOME/.rvm/scripts/rvm

if [ ! -d "$HOME/.rvm/rubies/ruby-$RUBY_VERSION" ]; then
	rvm install ruby-$RUBY_VERSION
else
	echo "Ruby $RUBY_VERSION already installed"
fi

