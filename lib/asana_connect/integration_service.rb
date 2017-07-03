class AsanaConnect::IntegrationService
  def initialize(deal_id)
    @deal = Deal.find_by_id deal_id
  end

  def perform
    begin
      send_deal
    rescue Exception => e
      log_error(e)
    end
  end

  private

  attr_reader :deal

  def send_deal
    return unless deal.present?
    task = asana_client.tasks.create task_params
    log_success(task)
  end

  def api_config
    @_api_config ||= deal.company.asana_connect_configurations.first
  end

  def task_params
    {
      workspace: workspace.id,
      projects: [project.id],
      name: deal.name,
      assignee: deal.user_with_highest_share.try(:email),
      notes: "Rep – #{deal.user_with_highest_share.try(:name)}
Advertiser – #{deal.advertiser.name}
Agency – #{deal.agency.try(:name) || 'N/A'}
Due Date – TBD
Budget – #{deal.budget_loc}
Flight Dates – #{deal.start_date.strftime('%m/%d/%Y')} to #{deal.end_date.strftime("%m/%d/%Y")}"
    }
  end

  def workspace
    @_workspace ||= asana_client.workspaces.find_all.first
  end

  def project
    return @_project if defined?(@_project)
    projects = asana_client.projects.find_by_workspace(workspace: workspace.id)
    @_project ||= projects.find{|el|el.name == api_config.network_code}
  end

  def asana_client
    @_asana_client ||= Asana::Client.new do |c|
      c.authentication :oauth2,
                       refresh_token: api_config.password,
                       client_id: ASANA_CONNECT.client_id,
                       client_secret: ASANA_CONNECT.client_secret,
                       redirect_uri: ASANA_CONNECT.redirect_uri
    end
  end

  def log_error(error)
    integration_log = IntegrationLog.new

    integration_log.object_name   = 'deal'
    integration_log.api_provider  = 'asana_connect'
    integration_log.company_id    = deal.company_id
    integration_log.deal_id       = deal.id
    integration_log.response_code = (error.cause.response[:status] rescue 500)
    integration_log.response_body = (error.errors.to_s rescue error.to_s)
    integration_log.is_error      = true
    integration_log.doctype       = 'json'

    integration_log.save
  end

  def log_success(task)
    integration_log = IntegrationLog.new

    integration_log.object_name   = 'deal'
    integration_log.api_provider  = 'asana_connect'
    integration_log.company_id    = deal.company_id
    integration_log.deal_id       = deal.id
    integration_log.response_code = 200
    integration_log.response_body = "Task #{task.name} has been created"
    integration_log.is_error      = false
    integration_log.doctype       = 'json'

    integration_log.save
  end
end
