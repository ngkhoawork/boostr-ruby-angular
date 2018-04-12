class Api::SspsController < ApplicationController
  respond_to :json

  def index
    render json: ssps_serializer
  end

  private

  def ssps_serializer
    ActiveModel::ArraySerializer.new(
      ssps,
      each_serializer: SspSerializer
    )
  end
  def ssps
    @_ssps = Ssp.all
  end
end
