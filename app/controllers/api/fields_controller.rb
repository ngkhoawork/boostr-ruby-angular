class Api::FieldsController < ApplicationController
  respond_to :json, :csv

  def index
    render json: fields
  end

  def client_base_options
    render json: client_base_options_data
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

  def client_base_options_data
    {
      categories: company.fields.client_category_fields.to_options,
      regions: company.fields.client_region_fields.to_options,
      segments: company.fields.client_segment_fields.to_options
    }
  end
end
