class Api::WorkflowCriterionsController < ApplicationController
  respond_to :json

  def destroy
    workflow_criterion.destroy
    render json: true
  end

  private

  def workflow
    @workflow ||= Workflow.find_by(id: params[:workflow_id], company_id: current_user.company_id)
  end

  def workflow_criterion
    @workflow_criterion ||= workflow.workflow_criterions.find(params[:id])
  end
end
