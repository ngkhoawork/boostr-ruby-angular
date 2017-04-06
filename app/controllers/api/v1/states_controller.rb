class Api::V1::StatesController < ApiController
  def index
    render json: UsaState.new.states
  end
end
