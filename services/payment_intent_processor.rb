class PaymentIntentProcessor
  def initialize(payment_intent)
    @payment_intent = payment_intent
  end

  def process
    account = @payment_intent.account
    DB.transaction do
      if (account.amount - @payment_intent.amount).round(2) >= 0
        account.update(amount: (account.amount - @payment_intent.amount).round(2))
        @payment_intent.update(status: 'success')
      else
        @payment_intent.update(status: 'insufficient_funds')
      end
    end
  end
end
