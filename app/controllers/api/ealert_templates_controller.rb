class Api::EalertTemplatesController < ApplicationController
  rescue_from ActiveRecord::RecordNotUnique, with: :pg_non_uniq_error_response

  def show
    render json: resource,
           serializer: Api::EalertTemplates::BaseSerializer
  end

  def update
    if resource.update(resource_params)
      render json: resource,
             serializer: Api::EalertTemplates::BaseSerializer
    else
      render json: { errors: resource.errors.messages },
             status: :unprocessable_entity
    end
  end

  def send_ealert
    Email::EalertTemplateService.new(*ealert_params).perform

    render nothing: true
  end

  private

  def resource
    company.ealert_templates.find_by!(type: type)
  end

  def company
    current_user.company
  end

  def resource_params
    params
      .require(:ealert_template)
      .permit(
        recipients: [],
        fields_attributes: [:id, :position]
      )
  end

  def type
    "EalertTemplate::#{params.require(:type).camelize}"
  end

  def ealert_params
    [resource, subject, ealert_recipients, params[:comment], params[:attached_asset_ids]]
  end

  def ealert_recipients
    params.require(:recipients).tap do |recipients|
      unless recipients.is_a?(Array) && recipients.select(&:present?).size > 0
        raise ActionController::ParameterMissing, 'recipients must be non-empty array'
      end
    end
  end

  def subject
    subject_class.find(params.require(:subject_id))
  end

  def subject_class
    params.require(:type).camelize.constantize
  end

  def pg_non_uniq_error_response(exception)
    error_detail = exception.message.match(/(?<=DETAIL:  ).+(?=\n)/).to_s

    render json: { errors: [error_detail] }, status: :unprocessable_entity
  end
end
