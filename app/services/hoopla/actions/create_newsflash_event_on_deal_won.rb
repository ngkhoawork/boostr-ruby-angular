class Hoopla::Actions::CreateNewsflashEventOnDealWon < Hoopla::Actions::Base
  include ActionView::Helpers::NumberHelper

  def self.required_option_keys
    super + %i(deal_id user_id)
  end

  def perform
    response = api_caller.create_newsflash_event(newsflash_event_options)

    if response.success?
      true
    else
      raise Hoopla::Errors::UnhandledRequest, response.body
    end
  rescue Hoopla::Errors::NewsflashEventFailed => e
    log_error(e.message)
  end

  private

  def deal
    @deal ||= Deal.find(@options[:deal_id])
  end

  def user
    @user ||= User.find(@options[:user_id])
  end

  def hoopla_user
    user.hoopla_user || raise_hoopla_user_must_present!(user.id)
  end

  def newsflash_event_options
    @options.merge(
      title: title,
      message: message,
      user_href: hoopla_user.href,
      newsflash_href: configuration.deal_won_newsflash_href
    )
  end

  def title
    "#{user.name} closed #{formatted_budget}"
  end

  def message
    "#{user.name} closed #{formatted_budget} deal for #{deal.name}!\n
    Start Date: #{formatted_start_date}\n
    End Date: #{formatted_end_date}"
  end

  def formatted_budget
    number_to_currency(deal.budget, unit: deal.currency&.curr_symbol.to_s, precision: 0)
  end

  def formatted_start_date
    deal.start_date&.strftime('%m/%d/%Y')
  end

  def formatted_end_date
    deal.end_date&.strftime('%m/%d/%Y')
  end

  def raise_hoopla_user_must_present!(user_id)
    raise Hoopla::Errors::NewsflashEventFailed, "hoopla user must be present for user_id: #{user_id}"
  end

  def log_error(message)
    IntegrationLog.create!(
      company_id: @options[:company_id],
      deal_id: @options[:deal_id],
      api_provider: 'hoopla',
      object_name: 'deal',
      is_error: true,
      error_text: message
    )
  end
end
