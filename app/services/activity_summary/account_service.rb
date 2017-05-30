class ActivitySummary::AccountService < ActivitySummary::BaseService
  AGENCY_TYPE = 'agency'.freeze

  def perform
    { client_activities: clients_activity_reports, total_activity_report: total_clients_activity_report }
  end

  private

  def clients_activity_reports
    clients_all_or_by_type.reduce([]) do |client_report, client|
      client_activities = client_activities_for(client)
        .map { |activity| { client_id: client.id, client_name: client.name, activity.name => activity.count } }
        .reduce({}, :merge)

      client_activities = { client_id: client.id, client_name: client.name } if client_activities.empty?

      client_activities[:total] = client_activities.values[2..-1].reduce(:+) || 0

      client_report << client_activities
    end
  end

  def total_clients_activity_report
    client_activities = activities_all_or_by_type.reduce do |memo, el|
      memo.merge(el) { |_k, old_v, new_v| old_v + new_v }
    end

    client_activities = {} if client_activities.nil?
    client_activities[:total] = client_activities.values.sum || 0
    client_activities
  end

  def grouped_by_activity_types_for_clients
    @_grouped_by_activity_types_for_clients ||= company
      .activities
      .with_activity_types
      .for_time_period(start_date, end_date)
  end

  def client_activities_for(client)
    client.agency? ? agency_activities(client) : advertiser_activities(client)
  end

  def advertiser_activities(advertiser)
    grouped_by_activity_types_for_clients.by_client(advertiser).group_by_activity_types_name
  end

  def agency_activities(agency)
    grouped_by_activity_types_for_clients.by_agency(agency).group_by_activity_types_name
  end

  def advertiser_id
    Client.advertiser_type_id(company)
  end

  def agency_id
    Client.agency_type_id(company)
  end

  def advertisers
    company.clients.by_type_id(advertiser_id)
  end

  def agencies
    company.clients.by_type_id(agency_id)
  end

  def advertiser_activities_grouped_by_type
    advertiser_activities(advertisers).map { |activity| { activity.name => activity.count } }
  end

  def agency_activities_grouped_by_type
    agency_activities(agencies).map { |activity| { activity.name => activity.count } }
  end

  def advertiser_and_agency_activities_grouped_by_type
    advertiser_activities_grouped_by_type + agency_activities_grouped_by_type
  end

  def activities_by_type
    client_type.downcase.eql?(AGENCY_TYPE) ? agency_activities_grouped_by_type : advertiser_activities_grouped_by_type
  end

  def activities_all_or_by_type
    client_type.present? ? activities_by_type : advertiser_and_agency_activities_grouped_by_type
  end

  def client_type
    @_client_type ||= params[:type]
  end

  def clients_by_type
    client_type.downcase.eql?(AGENCY_TYPE) ? agencies : advertisers
  end

  def clients_all_or_by_type
    client_type.present? ? clients_by_type : company.clients
  end
end
