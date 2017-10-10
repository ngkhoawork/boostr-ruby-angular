class Csv::SplitAdjustedDecorator
  def initialize(deal_member)
    @deal_member = deal_member
  end

  def name
    deal_member[:deal_name]
  end

  def advertiser
    deal_member[:advertiser]['name'] rescue nil
  end

  def agency
    deal_member[:agency]['name'] rescue nil
  end

  def team_member
    deal_member[:name]
  end

  def split
    deal_member[:share]
  end

  def stage
    deal_member[:stage]['name'] rescue nil
  end

  def %
    deal_member[:stage]['probability'] rescue nil
  end

  def currency
    deal_member[:curr_cd]
  end

  def budget
    deal_member[:budget_loc]
  end

  def budget_usd
    deal_member[:budget]
  end

  def split_budget_usd
    deal_member[:split_budget]
  end

  def method_missing(name)
    deal_member[name]
  end

  private

  attr_reader :deal_member
end
