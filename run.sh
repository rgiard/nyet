#!/usr/bin/env bash
. $HOME/.rvm/scripts/rvm
. $WORKSPACE/environment.sh

echo "Workspace: $WORKSPACE"
echo "Ruby version: $RUBY_VERSION"
rvm use $RUBY_VERSION
echo "Using $(ruby --version)"

rvm user gemsets
gem install bundler
bundle install

cd $WORKSPACE 
rspec services_spec/$1_isv_spec.rb

