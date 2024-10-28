module Subscriptions
  class << self
    def registered(app)
      app.get '/subscriptions/new' do
        erb :'subscriptions/new', layout: :layout
      end

      app.post '/subscriptions' do
        Subscription.create(price: params['price'], identifier: params['identifier'], created_at: Time.now.utc, updated_at: Time.now.utc)
        redirect to '/'
      end

      app.delete '/subscriptions/:id' do
        Subscription.first(id: params['id']).destroy
        redirect to '/'
      end
    end
  end
end
