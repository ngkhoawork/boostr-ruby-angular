class Api::V1::ClientsController < ApplicationController
  respond_to :json, :csv

  def index
    results = suggest_clients
    response.headers['X-Total-Count'] = results.count.to_s
    results = results.limit(limit).offset(offset)
    render json: results.as_json(
      methods: [:deals_count, :fields]
    )
  end

  def show
    render json: client
  end

  private

  def client
    @client ||= company.clients.where(id: params[:id]).first!
  end

  def company
    @company ||= current_user.company
  end
end
