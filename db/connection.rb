DB = Sequel.connect(
  ENV['DATABASE_URL'].present? ? ENV['DATABASE_URL'] : "postgres://#{ENV['USER']}:#{ENV['PASSWORD']}@#{ENV['HOST']}:#{ENV['PORT']}/#{ENV['DATABASE_NAME']}"
)

# migrations
unless DB.table_exists?(:accounts)
  DB.create_table :accounts do
    primary_key :id
    String :identifier
    Float :amount
    DateTime :created_at
    DateTime :updated_at
  end
end

unless DB.table_exists?(:subscriptions)
  DB.create_table :subscriptions do
    primary_key :id
    Float :price
    String :identifier
    DateTime :created_at
    DateTime :updated_at
  end
end

unless DB.table_exists?(:payment_intents)
  DB.create_table :payment_intents do
    primary_key :id
    String :subscription_identifier
    String :account_identifier
    Float :amount
    String :status
    DateTime :created_at
    DateTime :updated_at
  end
end

unless DB.table_exists?(:rebills)
  DB.create_table :rebills do
    primary_key :id
    String :subscription_identifier
    String :account_identifier
    Float :amount
    String :status
    DateTime :scheduled_at
    DateTime :created_at
    DateTime :updated_at
  end
end
