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
    deal.advertiser.name
  end

  def agency
    deal.agency.name if deal.agency.present?
  end

  def name
    object.user.name
  end

  def budget
    deal.budget.to_i
  end

  def stage
    deal.stage.probability
  end

  def type
    Deal.get_option(deal, 'Deal Type')
  end

  def source
    Deal.get_option(deal, 'Deal Sources')
  end

  def next_steps
    deal.next_steps
  end

  def start_date
    deal.start_date.strftime('%-m/%-d/%y')
  end

  def end_date
    deal.end_date.strftime('%-m/%-d/%y')
  end

  def created_date
    deal.created_at.strftime('%-m/%-d/%y')
  end

  def closed_date
    deal.closed_at.strftime('%-m/%-d/%y') if deal.closed_at.present?
  end

  private

  def deal
    @_deal ||= object.deal
  end
end
