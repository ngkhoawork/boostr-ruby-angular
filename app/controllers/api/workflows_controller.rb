class Api::WorkflowsController < ApplicationController
  respond_to :json

  def index
    render json: workflows, each_serializer: Workflows::WorkflowListSerializer
  end

  def create
    workflow = Workflow.new(workflow_params.merge(default_params))

    if workflow.save
      render json: workflow, status: :created
    else
      render json: { errors: workflow.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    if workflow.update(workflow_params)
      render json: workflow
    else
      render json: { errors: workflow.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    workflow.destroy

    render nothing: true
  end

  private

  def company
    @_company ||= current_user.company
  end

  def workflow_params
    params.require(:workflow).permit(
        :id,
        :name,
        :workflowable_type,
        :switched_on,
        :description,
        :fire_on_create,
        :fire_on_update,
        :fire_on_destroy,
        { workflow_action_attributes: [:id, :workflow_type, :workflow_method, :template, :api_configuration_id, slack_attachment_mappings: [:name, :label_name]] },
        { workflow_criterions_attributes: [:id, :base_object, :field, :math_operator, :relation, :value, :data_type] }
    )
  end

  def default_params
    { user_id: current_user.id, company_id: company.id }
  end

  def workflows
    Workflow.for_company(company.id).preload(
        :user,
        :workflow_action,
        :workflow_criterions
    )
  end

  def workflow
    @_workflow ||= Workflow.find_by(id: params[:id], company: company)
  end
end
