require 'rufus-scheduler'
require 'dotenv/load'
require 'bundler'

Bundler.require(:default)

require 'active_support/all'

Dir["./db/*.rb"].each {|file| require file }
Dir["./models/*.rb"].each {|file| require file }
Dir["./services/*.rb"].each {|file| require file }

scheduler = Rufus::Scheduler.new

scheduler.every '10s' do
  # Grab new pending rebills and scheduled ones
  rebills = Rebill.where(status: 'processing', scheduled_at: ..Time.now.utc).or(status: 'pending')
  rebills.each { |rebill| PartialRebillProcessor.new(rebill).process }
end