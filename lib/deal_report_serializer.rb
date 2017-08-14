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
    object.deal_members.each do |deal_member|
      data = deal_member.username.serializable_hash(only: [:id, :first_name, :last_name])
      data[:share] = deal_member.share
      users << data
    end

    users
  end

  def latest_activity
    object.latest_happened_activity.serializable_hash(only: [:happened_at, :activity_type_name, :comment]) rescue nil
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
    .reject{ |deal_product| deal_product.product_id != @options[:product_filter] if @options[:product_filter] }
    .map(&:id)

    object.deal_product_budgets
    .select{ |budget| selected_products.include?(budget.deal_product_id) }
    .group_by(&:start_date)
    .collect{|key, value| {start_date: key, budget: value.map(&:budget).compact.reduce(:+)} }
    # object.deal_product_budgets.map {|deal_product_budget| deal_product_budget.serializable_hash(only: [:id, :budget, :start_date, :end_date]) rescue nil}
  end

  def deal_custom_field
    object.deal_custom_field rescue nil
  end

  def close_reason
    get_deal_value_name 'Close Reason'
  end

  def team
    return nil if ordered_deal_members.blank?

    user_with_highest_share.leader? ? leader_team_name : user_name_with_highest_share
  end

  # def cache_key
  #   parts = []
  #   parts << object.id
  #   parts << object.updated_at
  #   parts << object.advertiser.try(:id)
  #   parts << object.advertiser.try(:updated_at)
  #   parts << object.stageinfo.try(:id)
  #   parts << object.stageinfo.try(:updated_at)
  #   parts << object.agency.try(:id)
  #   parts << object.agency.try(:updated_at)
  #   parts << object.deal_members.map(&:id)
  #   parts << object.deal_members.map(&:updated_at)
  #   parts << object.deal_product_budgets.try(:id)
  #   parts << object.deal_product_budgets.try(:updated_at)
  #   parts
  # end

  private

  def get_deal_value_name field_name
    if field = @options[:deal_settings_fields].find { |field| field.include? field_name }
      object.values.find { |value| value.field_id == field[0] }.try(:option).try(:name)
    end
  end

  def ordered_deal_members
    object.deal_members.ordered_by_share
  end

  def user_with_highest_share
    @_user_with_highest_share ||= ordered_deal_members.first.user
  end

  def leader_team_name
    Team.find_by(leader: user_with_highest_share).name
  end

  def user_name_with_highest_share
    user_with_highest_share.team.name rescue nil
  end
end
