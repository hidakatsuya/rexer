#!/bin/bash

cd /rexer-src && gem build rexer.gemspec -o /tmp/rexer.gem && gem install /tmp/rexer.gem
