class Api::V1::ActivityTypesController < ApplicationController
  def index
    render json: {msg: 'Status'}
  end
end
