require './helpers/utils.rb'

Dir["./db/*.rb"].each {|file| require file }
Dir["./models/*.rb"].each {|file| require file }
Dir["./services/*.rb"].each {|file| require file }

class RebillApp < Sinatra::Base
  include Utils

  use Rack::MethodOverride

  configure do
    set :views, ['./views']
  end

  get '/' do
    rebills = Rebill.order(:id).reverse.all
    erb :'rebill/list', layout: :layout, locals: { rebills: rebills }
  end

  get '/rebill' do
    erb :'rebill/form', layout: :layout
  end

  post '/rebill' do
    Rebill.create(
      account_identifier: params['account_identifier'],
      subscription_identifier: params['subscription_identifier'],
      amount: params['amount'],
      status: 'pending'
    )

    redirect '/rebill'
  end
end
