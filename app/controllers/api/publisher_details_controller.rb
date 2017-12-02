class Api::PublisherDetailsController < ApplicationController
  def extended_fields
    render json: Api::Publishers::ExtendedFieldsSerializer.new(publisher)
  end

  def associations
    render json: Api::Publishers::AssociationsSerializer.new(publisher)
  end

  def activities
    render json: by_pages(publisher_activities),
           each_serializer: Api::ActivitySerializer
  end

  private

  def publisher
    Publisher.find(params[:id])
  end

  def publisher_activities
    publisher.activities.order(id: :desc).preload(:creator, :activity_type, :client, :contacts, :deal)
  end
end
