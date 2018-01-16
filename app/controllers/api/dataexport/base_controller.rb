class Api::Dataexport::BaseController < ApiController
  include PagesHelper

  respond_to :json

  def index
    render json: by_pages(resouces), each_serializer: serializer_class
  end

  private

  def collection
    NotImplementedError
  end

  def serializer_class
    NotImplementedError
  end

  def resouces
    return @_resouces if defined? @_resouces

    @_resouces = collection.order(:updated_at)
    @_resouces = @_resouces.where('"updated_at" > ?', timestamp) if timestamp.present?

    @_resouces
  end

  def timestamp
    @_timestamp ||= params[:timestamp].present? ? Time.at(params[:timestamp].to_i) : nil
  end

  def default_per
    1000
  end
end
