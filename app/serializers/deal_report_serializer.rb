class DealReportSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :advertiser_id,
    :agency_id,
    :company_id,
    :start_date,
    :end_date,
    :name,
    :budget,
    :next_steps,
    :next_steps_due,
    :created_by,
    :advertiser,
    :stage_id,
    :stage,
    :agency,
    :deal_product_budgets,
    :deal_custom_field,
    :users,
    :latest_activity,
    :type,
    :source,
    :team
  )

  def stage
    object.stageinfo.serializable_hash rescue nil
  end

  def advertiser
    object.advertiser.serializable_hash(only: [:id, :name]) rescue nil
  end

  def agency
    object.agency.serializable_hash(only: [:id, :name], include: { parent_client: { only: [:id, :name] } }) rescue nil
  end

  def users
    users = []
    deal_members.each do |deal_member|
      data = deal_member.username.serializable_hash(only: [:id, :first_name, :last_name])
      data[:share] = deal_member.share
      users << data
    end

    users
  end

  def latest_activity
    object.latest_happened_activity.serializable_hash(only: [:happened_at, :activity_type_name]) rescue nil
  end

  def type
    get_deal_value_name 'Deal Type'
  end

  def source
    get_deal_value_name 'Deal Source'
  end

  def deal_product_budgets
    selected_products = object
    .deal_products
    .reject{ |deal_product| !@options[:product_filter].include?(deal_product.product_id) if @options[:product_filter] }
    .map(&:id)

    grouped_budgets = object.deal_product_budgets
    .select{ |budget| selected_products.include?(budget.deal_product_id) }
    .group_by{|budget| budget.start_date.beginning_of_month}
    .collect{|key, value| {start_date: key, budget: value.map(&:budget).compact.reduce(:+)} }

    budgets = []

    @options[:range].each do |product_time|
      if budget = grouped_budgets.find { |budget| budget[:start_date].try(:beginning_of_month) == product_time }
        budgets << budget[:budget].to_f.round
      else
        budgets << 0
      end
    end
    budgets
  end

  def deal_custom_field
    object.deal_custom_field rescue nil
  end

  def close_reason
    get_deal_value_name 'Close Reason'
  end

  def team
    return nil if deal_members.blank?
    get_team_name(deal_members.first.username)
  end

  private

  def get_deal_value_name field_name
    if field = @options[:deal_settings_fields].find { |field| field.include? field_name }
      object.values.find { |value| value.field_id == field[0] }.try(:option).try(:name)
    end
  end

  def deal_members
    object.deal_members_share_ordered
  end

  def get_team_name(user)
    team = @options[:company_teams_data].find{|team| team.leader_id == user.id}
    if !team.present?
      team = @options[:company_teams_data].find{|team| team.id == user.team_id}
    end
    team.name rescue nil
  end
end
