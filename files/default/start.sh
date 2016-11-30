#!/bin/bash  --login
cd ..
source ~/.rvm/scripts/rvm
set -x
rvm reinstall 2.3.0
rvm use 2.3.0
rvm gemset create sinatra230
rvm gemset use sinatra230
gem install sinatra --no-ri --no-doc
#gem install rack --no-ri --no-doc
gem install rack-test --no-ri --no-doc
gem install simplecov --no-ri --no-doc
gem install simplecov-rcov --no-ri --no-doc
#gem install bundle --no-ri --no-doc
gem install rspec --no-ri --no-doc

rackup config.ru --port 9292 -o 0.0.0.0 &
#rackup config.ru --port 9292 &

