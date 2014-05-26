#!/usr/bin/env bash
. environment.sh
. $HOME/.rvm/scripts/rvm

echo `ruby --version`
echo rvm use $RUBY_VERSION
rvm use $RUBY_VERSION
echo `ruby --version`

type rvm | head -n 1
rvm user gemsets
gem install bundler
bundle install

cd $WORKSPACE 
rspec services_spec/cleardb_isv_spec.rb
