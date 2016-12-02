class Api::InactivesController < ApplicationController
  respond_to :json

  def index
    render json: {
      inactives: inactives
    }
  end

  private

  def inactives
    inactives = []
    advertisers_with_revenues.each do |advertiser|
      current_quarter_revenues = advertiser.revenues.select do |rev|
        rev.start_date <= Date.today && rev.end_date >= Date.today.beginning_of_quarter
      end
      next if current_quarter_revenues.any?
      last_activity = advertiser.activities.sort_by(&:happened_at).last
      sellers = advertiser.users.select do |user|
        user.user_type == SELLER ||
        user.user_type == SALES_MANAGER
      end

      inactives << {
        id: advertiser.id,
        client_name: advertiser.name,
        average_spend: nil,
        open_pipeline: nil,
        last_activity: last_activity.as_json(override: true, only: [:id, :name, :happened_at, :activity_type_name, :comment]),
        sellers: sellers.map(&:name)
      }
    end

    inactives
  end

  def advertisers_with_revenues
    company.clients
      .by_type_id(advertiser_type_id)
      .by_category(params[:category_id])
      .by_subcategory(params[:subcategory_id])
      .joins("LEFT JOIN revenues ON clients.id = revenues.client_id")
      .where('revenues.start_date <= ? AND revenues.end_date >= ?', period.last, period.first)
      .group("clients.id")
      .includes(:revenues, :activities, :users)
  end

  def advertiser_type_id
    Client.advertiser_type_id(current_user.company)
  end

  def company
    @company ||= current_user.company
  end

  def period
    qtr_offset = (params[:qtrs] || 2).to_i
    date = Date.today << (qtr_offset * 3)
    date.beginning_of_quarter..Date.today
  end
end
