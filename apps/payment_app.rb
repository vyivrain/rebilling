# dependency files
require 'active_support/all'

require './helpers/utils.rb'
Dir["./db/*.rb"].each {|file| require file }
Dir["./routes/*.rb"].each {|file| require file }
Dir["./models/*.rb"].each {|file| require file }
Dir["./services/*.rb"].each {|file| require file }

class PaymentApp < Sinatra::Base
  include Utils

  register Accounts # account endpoints
  register Subscriptions # subscription endpoints

  use Rack::MethodOverride

  configure do
    set :views, ['./views']
    set :show_exceptions, false
  end

  before do
    if request.content_type == 'application/json'
      begin
        @request_payload = JSON.parse(request.body.read)
      rescue JSON::ParserError
        halt 400, { error: 'Invalid JSON' }.to_json
      end
    end
  end

  # Payment endpoint
  post '/paymentIntents/create' do
    subscription = Subscription.first(identifier: @request_payload['subscription_identifier'])
    raise(RecordNotFoundException, "Subscription #{@request_payload['subscription_identifier']} is missing") unless subscription.present?
    account = Account.first(identifier: @request_payload['account_identifier'])
    raise(RecordNotFoundException, "Account #{@request_payload['account_identifier']} is missing") unless account.present?
    raise(ConditionFailedException, "Amount specified is not a number") unless valid_float?(@request_payload['amount'])
    raise(ConditionFailedException, "Amount specified is higher than subscription price") if Float(@request_payload['amount']) > subscription.price

    payment_intent = PaymentIntent.create(
      amount: Float(@request_payload['amount']),
      account_identifier: @request_payload['account_identifier'],
      subscription_identifier: @request_payload['subscription_identifier'],
    )

    PaymentIntentProcessor.new(payment_intent).process

    { status: payment_intent.status }.to_json
  end

  error ConditionFailedException, Sequel::ValidationFailed, RecordNotFoundException, UnhandledException do
    halt 400, {'Content-Type' => 'application/json'}, { status: 'failed', message: env['sinatra.error'].message }.to_json
  end

  get '/' do
    accounts = Account.all
    subscriptions = Subscription.all

    erb :'home', layout: :layout, locals: { accounts: accounts, subscriptions: subscriptions }
  end

  get '/payment_intents' do
    payment_intents = PaymentIntent.order(:id).reverse.all
    erb :'payment_intents/list', layout: :layout, locals: { payment_intents: payment_intents }
  end
end
