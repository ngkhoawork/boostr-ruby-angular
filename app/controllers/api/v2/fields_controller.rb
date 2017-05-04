class Api::V2::FieldsController < ApiController
  respond_to :json

  def index
    render json: fields
  end

  private

  def company
    @company ||= current_user.company
  end

  def subject
    params[:subject]
  end

  def fields
    @fields ||= company.fields.where(subject_type: subject)
  end
end
