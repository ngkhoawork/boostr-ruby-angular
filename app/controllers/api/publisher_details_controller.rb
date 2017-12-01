class Api::PublisherDetailsController < ApplicationController
  def activities
    render json: by_pages(publisher_activities),
           each_serializer: Api::ActivitySerializer
  end

  private

  def publisher_activities
    publisher.activities.order(id: :desc).preload(:creator, :activity_type, :client, :contacts, :deal)
  end

  def publisher
    Publisher.find(params[:id])
  end
end
