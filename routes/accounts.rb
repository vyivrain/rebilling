module Accounts
  class << self
    def registered(app)
      app.get '/accounts/new' do
        erb :'accounts/new', layout: :layout
      end

      app.post '/accounts' do
        Account.create(amount: params['amount'], identifier: params['identifier'], created_at: Time.now.utc, updated_at: Time.now.utc)
        redirect to '/'
      end

      app.delete '/accounts/:id' do
        Account.first(id: params['id']).destroy
        redirect to '/'
      end
    end
  end
end
