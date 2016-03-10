class Api::RevenueController < ApplicationController
  respond_to :json

  def index
    render json: revenues
  end

  def create
    csv_file = IO.read(params[:file].tempfile.path)
    revenues = Revenue.import(csv_file, current_user.company.id)

    render json: revenues
  end

  def team
    if current_user.leader?
      current_user.teams.first
    else
      current_user.team
    end
  end

  def revenues
    rss = []
    if params[:filter] == 'all' && current_user.leader?
      rss = current_user.company.revenues
    elsif params[:filter] == 'team'
      team.members.each do |m|
        m.clients.each do |c|
          c.revenues.each do |r|
            rss += [r] if !rss.include?(r)
          end
        end
      end
    elsif params[:filter] == 'upside'
      if current_user.leader?
        current_user.teams.first.all_members.each do |m|
          m.clients.each do |c|
            if c.client_members.where(user_id: m.id).first.share > 0
              c.revenues.where("revenues.balance > 0").each do |r|
                rss += [r] if !rss.include?(r)
              end
            end
          end
        end
      else
        current_user.clients.each do |c|
          if c.client_members.where(user_id: current_user.id).first.share > 0
            c.revenues.where("revenues.balance > 0").each do |r|
              rss += [r] if !rss.include?(r)
            end
          end
        end
      end
    elsif params[:filter] == 'risk'
      if current_user.leader?
        current_user.teams.first.all_members.each do |m|
          m.clients.each do |c|
            if c.client_members.where(user_id: m.id).first.share > 0
              c.revenues.where("revenues.balance < 0").each do |r|
                rss += [r] if !rss.include?(r)
              end
            end
          end
        end
      else
        current_user.clients.each do |c|
          if c.client_members.where(user_id: current_user.id).first.share > 0
            c.revenues.where("revenues.balance < 0").each do |r|
              rss += [r] if !rss.include?(r)
            end
          end
        end
      end
    else # mine/default
      current_user.clients.each do |c|
        c.revenues.each do |r|
          rss += [r] if !rss.include?(r)
        end
      end
    end
    return rss
  end
end
