require 'dotenv/load'
require 'bundler'

Bundler.require(:default)

require 'active_support/all'

# Rebill App
require './apps/rebill_app'
run RebillApp
