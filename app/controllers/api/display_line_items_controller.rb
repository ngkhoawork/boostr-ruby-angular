class Api::DisplayLineItemsController < ApplicationController
  respond_to :json

  def index
    render json: display_line_items.where("balance > 0").as_json( include: {
        io: {
            include: {
                advertiser: {},
                agency: {}
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
    io_ids = Io.joins(:io_members).where("io_members.user_id in (?)", member_ids.uniq).all.collect{|io| io.id}.uniq
    if params[:filter] == 'upside'
      DisplayLineItem.where("balance > 0 and io_id in (?)", io_ids)
    elsif params[:filter] == 'risk'
      DisplayLineItem.where("balance < 0 and io_id in (?)", io_ids)
    else
      DisplayLineItem.where("io_id in (?)", io_ids)
    end
  end

  def company
    current_user.company
  end
end
