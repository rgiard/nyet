#!/usr/bin/env bash
. environment.sh
. $HOME/.rvm/scripts/rvm

rvm use --ruby-version $RUBY_VERSION

type rvm | head -n 1
rvm user gemsets
gem install bundler
bundle install

cd $WORKSPACE 
rspec services_spec/cleardb_isv_spec.rb
