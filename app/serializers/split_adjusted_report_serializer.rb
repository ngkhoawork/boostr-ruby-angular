class SplitAdjustedReportSerializer < ActiveModel::Serializer
  attributes :name, :share, :deal_id, :deal_name, :advertiser, :agency, :budget, :stage, :type, :source, :next_steps,
             :start_date, :end_date, :created_date, :closed_date

  def deal_id
    object.deal_id
  end

  def deal_name
    deal.name
  end

  def advertiser
    deal.advertiser.serializable_hash(only: [:id, :name]) rescue nil
  end

  def agency
    deal.agency.serializable_hash(only: [:id, :name]) rescue nil if deal.agency.present?
  end

  def name
    object.user.name
  end

  def budget
    deal.budget.to_i
  end

  def stage
    deal.stage.serializable_hash(only: [:name, :probability]) rescue nil
  end

  def type
    deal.get_option_value_from_raw_fields(@options[:deal_settings_fields], 'Deal Type')
  end

  def source
    deal.get_option_value_from_raw_fields(@options[:deal_settings_fields], 'Deal Source')
  end

  def next_steps
    deal.next_steps
  end

  def start_date
    deal.start_date
  end

  def end_date
    deal.end_date
  end

  def created_date
    deal.created_at
  end

  def closed_date
    deal.closed_at if deal.closed_at.present?
  end

  private

  def deal
    @_deal ||= object.deal
  end
end
