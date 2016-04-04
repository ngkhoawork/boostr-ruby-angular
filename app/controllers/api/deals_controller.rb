class Api::DealsController < ApplicationController
  respond_to :json, :zip

  def index
    respond_to do |format|
      format.json {
        if params[:name].present?
          render json: suggest_deals
        else
          render json: ActiveModel::ArraySerializer.new(deals.for_client(params[:client_id]).includes(:advertiser, :stage).distinct , each_serializer: DealIndexSerializer).to_json 
        end
      }
      format.zip {
        if current_user.leader?
          deals = company.deals
        elsif team.present?
          deals = team.deals
        else
          deals = current_user.deals
        end
        send_data deals.to_zip, filename: "deals-#{Date.today}.zip"
      }
    end
  end

  def show
    deal
  end

  def create
    @deal = company.deals.new(deal_params)

    deal.created_by = current_user.id
    deal.updated_by = current_user.id

    if deal.save
      render json: deal, status: :created
    else
      render json: { errors: deal.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    deal.updated_by = current_user.id
    if deal.update_attributes(deal_params)
      render deal
    else
      render json: { errors: deal.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    deal.destroy

    render nothing: true
  end

  private

  def deal_params
    params.require(:deal).permit(:name, :stage_id, :budget, :start_date, :end_date, :advertiser_id, :agency_id, :closed_at, :next_steps, { values_attributes: [:id, :field_id, :option_id, :value] })
  end

  def deal
    @deal ||= company.deals.find(params[:id])
  end

  def company
    @company ||= current_user.company
  end

  def deals
    if params[:filter] == 'company' && current_user.leader?
      company.deals
    elsif params[:filter] == 'team' && team.present?
      team.deals
    else
      current_user.deals
    end
  end

  def team
    if current_user.leader?
      company.teams.where(leader: current_user).first
    else
      current_user.team
    end
  end

  def suggest_deals
    return @search_deals if defined?(@search_deals)

    @search_deals = company.deals.open.where('deals.name ilike ?', "%#{params[:name]}%").limit(10)
  end
end
