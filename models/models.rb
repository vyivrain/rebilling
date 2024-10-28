require './helpers/utils'

class Account < Sequel::Model
  one_to_many :payment_intents, key: :account_identifier, primary_key: :identifier
end

class Subscription < Sequel::Model
  one_to_many :payment_intents, key: :subscription_identifier, primary_key: :identifier
end

class PaymentIntent < Sequel::Model
  include Utils

  STATUSES = %w[insufficient_funds failed success].freeze

  many_to_one :account, key: :account_identifier, primary_key: :identifier
  many_to_one :subscription, key: :subscription_identifier, primary_key: :identifier

  def validate
    super

    errors.add(:subscription_identifier, 'cannot be empty') if !subscription_identifier || subscription_identifier.empty?
    errors.add(:account_identifier, 'cannot be empty') if !account_identifier || account_identifier.empty?
    errors.add(:amount, 'cannot be empty or below 0') if !amount || !valid_float?(amount) || Float(amount) < 0
    errors.add(:status, "not in allowed statuses. Applied status #{status} to payment intent") if status.present? && STATUSES.exclude?(status)
  end
end

class Rebill < Sequel::Model
  include Utils

  STATUSES = %w[pending processing cancelled processed].freeze

  many_to_one :account, key: :account_identifier, primary_key: :identifier
  many_to_one :subscription, key: :subscription_identifier, primary_key: :identifier

  def validate
    super

    errors.add(:subscription_identifier, 'cannot be empty') if !subscription_identifier || subscription_identifier.empty?
    errors.add(:account_identifier, 'cannot be empty') if !account_identifier || account_identifier.empty?
    errors.add(:amount, 'cannot be empty or below 0') if !amount || !valid_float?(amount) || Float(amount) < 0
    errors.add(:status, "not in allowed statuses. Applied status #{status} to rebill") if STATUSES.exclude?(status)
  end
end
