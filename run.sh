#!/usr/bin/env bash
. $WORKSPACE/environment.sh
. $HOME/.rvm/scripts/rvm

rvm use $RUBY_VERSION
echo "Using $(ruby --version)"

rvm user gemsets
gem install bundler
bundle install

cd $WORKSPACE 
rspec services_spec/cleardb_isv_spec.rb

