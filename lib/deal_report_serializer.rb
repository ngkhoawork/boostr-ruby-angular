class DealReportSerializer < ActiveModel::Serializer
  cached

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
    if activity = object.latest_happened_activity
      {
        date: activity.happened_at.strftime("%m-%d-%Y %H:%M:%S"),
        type: activity.activity_type_name,
        note: activity.comment
      }
    end
  end

  def type
    get_deal_value_name 'Deal Type'
  end

  def source
    get_deal_value_name 'Deal Source'
  end

  def deal_product_budgets
    object.deal_product_budgets.group_by(&:start_date)
    .collect{|key, value| {start_date: key, budget: value.map(&:budget).compact.reduce(:+)} }
    # object.deal_product_budgets.map {|deal_product_budget| deal_product_budget.serializable_hash(only: [:id, :budget, :start_date, :end_date]) rescue nil}
  end

  def deal_custom_field
    object.deal_custom_field rescue nil
  end

  def close_reason
    get_deal_value_name 'Close Reason'
  end

  def cache_key
    parts = []
    parts << object.id
    parts << object.updated_at
    parts << object.advertiser.try(:id)
    parts << object.advertiser.try(:updated_at)
    parts << object.stageinfo.try(:id)
    parts << object.stageinfo.try(:updated_at)
    parts << object.agency.try(:id)
    parts << object.agency.try(:updated_at)
    parts << object.deal_members.map(&:id)
    parts << object.deal_members.map(&:updated_at)
    parts << object.deal_product_budgets.try(:id)
    parts << object.deal_product_budgets.try(:updated_at)
    parts
  end

  private

  def get_deal_value_name field_name
    if field = @options[:deal_settings_fields].find { |field| field.include? field_name }
      object.values.find { |value| value.field_id == field[0] }.try(:option).try(:name)
    end
  end
end
