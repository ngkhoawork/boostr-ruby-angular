class Api::CurrenciesController < ApplicationController
  respond_to :json

  def index
    respond_to do |format|
      format.json {
        render json: Currency.all
      }
    end
  end

  def active_currencies
    render json: Currency.where(curr_cd: company.active_currencies)
  end

  def exchange_rates_by_currencies
    currencies = Currency.with_exchange_rates_for(company.id)
    render json: currencies.as_json(include: :exchange_rates)
  end

  private

  def company
    @company = current_user.company
  end
end
