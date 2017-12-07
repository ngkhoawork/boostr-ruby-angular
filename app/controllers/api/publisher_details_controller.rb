class Api::PublisherDetailsController < ApplicationController
  def show
    render json: Api::Publishers::ShowSerializer.new(publisher)
  end

  # TODO: remove, as 'show' includes it
  def extended_fields
    render json: Api::Publishers::ExtendedFieldsSerializer.new(publisher)
  end

  # TODO: remove, as 'show' includes it
  def associations
    render json: Api::Publishers::AssociationsSerializer.new(publisher)
  end

  def activities
    render json: by_pages(publisher_activities),
           each_serializer: Api::ActivitySerializer
  end

  def fill_rate_by_month_graph
    render json: PublisherFillRateByMonthGraphService.new(publisher).perform
  end

  def daily_revenue_graph
    render json: PublisherDailyRevenueGraphService.new(publisher).perform
  end

  private

  def publisher
    Publisher.find(params[:id])
  end

  def publisher_activities
    publisher.activities.order(id: :desc).preload(:creator, :activity_type, :client, :contacts, :deal)
  end
end
