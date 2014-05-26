#!/usr/bin/env bash
. $HOME/.rvm/scripts/rvm

type rvm | head -n 1
rvm user gemsets
gem install bundler
bundle install

cd $WORKSPACE 
rspec services_spec/cleardb_isv_spec.rb
