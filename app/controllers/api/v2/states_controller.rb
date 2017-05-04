class Api::V2::StatesController < ApiController
  def index
    render json: UsaState.new.states
  end
end
