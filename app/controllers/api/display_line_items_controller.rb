class Api::DisplayLineItemsController < ApplicationController
  respond_to :json

  def index
    render json: display_line_items.as_json( include: {
        io: {
            include: {
                advertiser: {},
                agency: {},
                currency: { only: :curr_symbol }
            }
        }
    })
  end

  def create
    if params[:file].present?
      require 'timeout'
      begin
        csv_file = File.open(params[:file].tempfile.path, "r:ISO-8859-1")
        errors = DisplayLineItem.import(csv_file, current_user)
        render json: errors
      rescue Timeout::Error
        return
      end
    end
  end

  private
  def display_line_items
    member_ids = [current_user.id]
    if current_user.leader?
      member_ids += current_user.teams.first.all_members.collect{|m| m.id}
      member_ids += current_user.teams.first.all_leaders.collect{|m| m.id}
    end
    io_ids = Io.where(company: current_user.company)
    if params[:filter] == 'upside'
      DisplayLineItem.where("io_id in (?)", 131)
    elsif params[:filter] == 'risk'
      DisplayLineItem.where("io_id in (?)", 131)
    else
      DisplayLineItem.where("io_id in (?)", 131)
    end
  end

  def company
    current_user.company
  end
end
