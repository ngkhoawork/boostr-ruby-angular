class Api::TimeDimensionsController < ApplicationController
  def index
    time_dimensions = TimeDimension.all
    render json: time_dimensions
  end
end