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
    :users,
    :latest_activity,
  )

  def stage
    object.stage.serializable_hash(only: [:id, :name, :probability, :open]) rescue nil
  end

  def advertiser
    object.advertiser.serializable_hash(only: [:id, :name]) rescue nil
  end

  def agency
    object.agency.serializable_hash(only: [:id, :name]) rescue nil
  end

  def users
    users = []
    object.users.each do |user|
      deal_member = object.deal_members.where(user_id: user.id).first
      data = user.serializable_hash(only: [:id, :first_name, :last_name])
      data[:share] = deal_member.share
      users << data
    end
    users
  end

  def latest_activity
    activities = object.activities.order("happened_at desc")
    if activities && activities.count > 0
      last_activity = activities.first
      data = ""
      if last_activity.happened_at
        data = data + "Date: " + last_activity.happened_at.strftime("%m-%d-%Y %H:%M:%S") + "<br/>"
      end
      if last_activity.activity_type_name
        data = data + "Type: " + last_activity.activity_type_name + "<br/>"
      end
      if last_activity.comment
        data = data + "Note: " + last_activity.comment
      end
      data
    else
      ""
    end
  end

  def deal_product_budgets
    object.deal_product_budgets.group("start_date").select("sum(deal_product_budgets.budget) as budget, start_date").collect{|product| product.serializable_hash(only: [:budget, :start_date])}
    # object.deal_product_budgets.map {|deal_product_budget| deal_product_budget.serializable_hash(only: [:id, :budget, :start_date, :end_date]) rescue nil}
  end

  def close_reason
    Deal.get_option(object, "Close Reason")
  end

  def cache_key
    parts = []
    parts << object.id
    parts << object.updated_at
    parts << object.advertiser.try(:id)
    parts << object.advertiser.try(:updated_at)
    parts << object.stage.try(:id)
    parts << object.stage.try(:updated_at)
    parts << object.agency.try(:id)
    parts << object.agency.try(:updated_at)
    parts << object.users.try(:id)
    parts << object.users.try(:updated_at)
    parts << object.deal_product_budgets.try(:id)
    parts << object.deal_product_budgets.try(:updated_at)
    parts
  end
end

