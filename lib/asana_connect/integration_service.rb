class AsanaConnect::IntegrationService
  def initialize(deal_id)
    @deal = Deal.find_by_id deal_id
  end

  def perform
    return unless @deal.present?
    begin
      send_deal
      set_deal_custom_field
    rescue Exception => e
      log_error(e)
    end
  end

  private

  attr_reader :deal, :task

  def send_deal
    @task = asana_client.tasks.create task_params
    log_success
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
Flight Dates – #{deal.start_date.strftime('%m/%d/%Y')} to #{deal.end_date.strftime("%m/%d/%Y")}"
    }
  end

  def workspace
    @_workspace ||= workspaces.find{|el|el.name.casecmp(api_config.asana_connect_details.workspace_name) == 0}
    raise "No workspace #{api_config.asana_connect_details.workspace_name} was found" unless @_workspace
    @_workspace
  end

  def workspaces
    asana_client.workspaces.find_all
  end

  def project
    @_project ||= projects.find{|el|el.name.casecmp(api_config.asana_connect_details.project_name) == 0}
    raise "No project #{api_config.asana_connect_details.project_name} was found" unless @_project
    @_project
  end

  def projects
    asana_client.projects.find_by_workspace(workspace: workspace.id)
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
    integration_log.assign_attributes(log_params)

    integration_log.response_code = (error.cause.response[:status] rescue 500)
    integration_log.response_body = (error.errors.to_s rescue error.to_s)
    integration_log.is_error      = true
    integration_log.api_endpoint  = "https://app.asana.com/"

    integration_log.save
  end

  def log_success
    integration_log = IntegrationLog.new
    integration_log.assign_attributes(log_params)

    integration_log.response_code = 200
    integration_log.response_body = "Task #{task.name} has been created"
    integration_log.is_error      = false
    integration_log.api_endpoint  = asana_task_link

    integration_log.save
  end

  def log_params
    {
      api_provider: 'asana_connect',
      object_name: 'deal',
      company_id: deal.company_id,
      deal_id: deal.id,
      doctype: 'json'
    }
  end

  def set_deal_custom_field
    dcfn = deal.company.deal_custom_field_names.where('disabled IS NOT TRUE').where('field_label ilike ?', 'Asana URL').first
    return unless dcfn.present?
    dcf = deal.deal_custom_field
    dcf = deal.build_deal_custom_field unless dcf.present?
    dcf.update(dcfn.field_name => asana_task_link)
  end

  def asana_task_link
    "https://app.asana.com/0/#{project&.id}/#{@task&.id}"
  end
end
