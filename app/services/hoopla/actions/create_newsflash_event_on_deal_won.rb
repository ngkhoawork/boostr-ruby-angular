class Hoopla::Actions::CreateNewsflashEventOnDealWon < Hoopla::Actions::Base
  include ActionView::Helpers::NumberHelper

  def self.required_option_keys
    super + %i(deal_id user_id)
  end

  def perform
    response = api_caller.create_newsflash_event(create_newsflash_event_options)

    if response.success?
      true
    else
      raise Hoopla::Errors::UnhandledRequest, response.body
    end
  end

  private

  def deal
    @deal ||= Deal.find(@options[:deal_id])
  end

  def user
    @user ||= User.find(@options[:user_id])
  end

  def hoopla_user
    user.hoopla_user || (raise 'hoopla_user does not exist')
  end

  def create_newsflash_event_options
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
end
