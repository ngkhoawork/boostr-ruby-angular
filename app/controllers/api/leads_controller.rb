class Api::LeadsController < ApplicationController
  respond_to :json

  def index
    
  end

  def accept
    lead.update(status: Lead::ACCEPTED)

    render nothing: true
  end

  def reject
    lead.update(status: Lead::REJECTED)

    render nothing: true
  end

  private

  def lead
    Lead.find(params[:id])    
  end
end
