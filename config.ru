require 'dotenv/load'
require 'bundler'

Bundler.require(:default)

require 'active_support/all'

# Payment Api App
require './apps/payment_app'
run PaymentApp
