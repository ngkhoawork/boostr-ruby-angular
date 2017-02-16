class Api::ExchangeRatesController < ApplicationController
  respond_to :json

  def create
    exchange_rate = company.exchange_rates.new(exchange_rate_params)
    if exchange_rate.save
      render json: exchange_rate, status: :created
    else
      render json: { errors: exchange_rate.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    if exchange_rate.update_attributes(exchange_rate_params)
      render json: exchange_rate, status: :accepted
    else
      render json: { errors: exchange_rate.errors.messages }, status: :unprocessable_entity
    end
  end

  def active_exchange_rates
    render json: company.exchange_rates.where('start_date <= ? AND end_date >= ?', Date.today, Date.today).includes(:currency).as_json(include: :currency)
  end

  def destroy
    exchange_rate.destroy
    render nothing: true
  end

  private

  def exchange_rate
    @exchange_rate ||= company.exchange_rates.find(params[:id])
  end

  def exchange_rate_params
    params.require(:exchange_rate).permit(
      :currency_id,
      :rate,
      :start_date,
      :end_date
    )
  end

  def company
    @company = current_user.company
  end
end
