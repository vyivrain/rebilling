require 'active_support/all'

class PartialRebillProcessor
  EXPECTED_PAYMENT_RESPONSE_STATUSES = %w[success insufficient_funds].freeze

  def initialize(rebill)
    @rebill = rebill
    @subscription = @rebill.subscription
  end

  def process
    payment_processed = false
    amounts = calculate_amounts_for_intents

    amounts.each do |amount|
      response = request_payment_intent(amount)
      case response['status']
      when 'success'
        handle_success_response(amount)
        payment_processed = true
        break
      when 'insufficient_funds'
      else
        @rebill.update(status: 'cancelled')
        raise UnhandledException, "Unhandled status - #{response}"
      end
    end

    unless payment_processed
      @rebill.update(status: 'cancelled')
    end
  end

  private

  def request_payment_intent(amount)
    response = HTTParty.post(
      "#{ENV['PAYMENT_API_URL']}/paymentIntents/create",
      body: {
        amount: amount,
        subscription_identifier: @rebill.subscription.identifier,
        account_identifier: @rebill.account.identifier
      }.to_json,
      headers: {
        'Content-Type': 'application/json'
      }
    )

    begin
      json_response = JSON.parse(response.body)
    rescue JSON::ParserError
      raise UnhandledException, "Can't parse payment api response - #{response.body}"
    end

    json_response
  end

  def calculate_amounts_for_intents
    if @rebill.scheduled_at.present?
      [@rebill.amount]
    else
      ENV['PERCENTAGES']&.split(',').map { |percentage| @rebill.amount * Float(percentage) / 100 }
    end
  end

  def handle_success_response(amount)
    if (@rebill.amount - amount).round(2) == 0
      @rebill.update(amount: (@rebill.amount - amount).round(2), status: 'processed')
    else
      @rebill.update(amount: (@rebill.amount - amount).round(2), scheduled_at: ENV['SCHEDULE_TIME_IN_HOURS']&.to_i&.hours&.since, status: 'processing')
    end
  end
end
