class ContactsSearchService < BaseService
  def perform
    filtered_result
  end

  private

  def limit
    params[:per].present? ? params[:per].to_i : 20
  end

  def offset
    params[:page].present? ? (params[:page].to_i - 1) * limit : 0
  end

  def search_result
    return unassigned_contacts if params[:unassigned] == 'yes'
    return suggested_contacts if params[:q].present?
    return activity_contacts if params[:activity].present?
    all_contacts
  end

  def activity_contacts
    @_activity_contacts ||= current_user_contacts
                              .where.not(activity_updated_at: nil)
                              .order(activity_updated_at: :desc)
                              .limit(10)
  end

  def all_contacts
    case tab_params
      when 'my_contacts'
        Contact.by_client_ids(current_user.clients.ids)
      when 'team'
        team_contacts
      else
        current_user_contacts
    end
  end

  def team_contacts
    return Contact.by_client_ids(current_user_team_clients) if current_user_team.present?
    current_user_contacts
  end

  def filtered_result
    search_result.by_primary_client_name(primary_client_criteria)
                 .by_city(city_criteria)
                 .by_job_level(job_level_criteria)
                 .by_country(country_criteria)
                 .by_last_touch(params[:start_date], params[:end_date])
  end

  def unassigned_contacts
    current_user_contacts.unassigned(current_user.id)
  end

  def suggested_contacts
    @_suggested_contacts ||=
      current_user_contacts
        .joins('LEFT JOIN clients ON clients.id = contacts.client_id')
        .joins('LEFT JOIN addresses ON contacts.id=addresses.addressable_id and addresses.addressable_type=\'Contact\'')
        .where('contacts.name ilike :contact_name OR clients.name ilike :client_name OR addresses.email ilike :email',
              contact_name: "%#{params[:q]}%", client_name: "%#{params[:q]}%", email: "%#{params[:q]}%")
  end

  def current_user_contacts
    @user_contacts ||= current_user.company.contacts.order(:name)
  end

  def current_user_team_clients
    current_user_team.clients.ids
  end

  def current_user_team
    if current_user.leader?
      current_user.company.teams.find_by(leader: current_user)
    else
      current_user.team
    end
  end

  def primary_client_criteria
    params[:workplace]
  end

  def city_criteria
    params[:city]
  end

  def job_level_criteria
    params[:job_level]
  end

  def country_criteria
    params[:country]
  end

  def tab_params
    params[:filter]
  end
end
