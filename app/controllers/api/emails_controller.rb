class Api::EmailsController < ApplicationController
  def create
    @text = params[:text]
    @html = params[:html]
    @from = params[:from]
    @to = params[:to].split("@")[0]
    @fn = to.split(".")[0]
    @token = to.split(".")[1]
    @subject = params[:subject]

    case @fn
    when "aef"
      parse_activity_email_followup
    when "event"
      parse_new_event_id
    end
  end

  protected

  def parse_activity_email_followup
    activity_uuid = @token
    activity = Activity.where(uuid: activity_uuid).first
    if activity
      comment = @text.split("-------").first
      activity.comment = comment
      activity.save
    end
  end

  def parse_new_event_id
    activity = Activity.where(uuid: @token).first
    if activity
      if match = @html.match(/eid=([A-Za-z0-9]{32})/)
        eid = match.captures.last

        activity.google_event_id = eid
        activity.save
      end
    end
  end
end
