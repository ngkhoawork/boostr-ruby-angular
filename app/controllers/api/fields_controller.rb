class Api::FieldsController < ApplicationController
  respond_to :json, :csv

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
    @fields ||= company.fields.includes(options: [:suboptions]).where(subject_type: subject)
  end

end
