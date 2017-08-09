class Csv::InfluencerBudgetDetailDecorator
  EMPTY_LINE = ''.freeze

  def initialize(influencer_content_fee)
    @influencer_content_fee = influencer_content_fee
    @content_fee = influencer_content_fee.content_fee
    @io = influencer_content_fee.content_fee.io
    @deal = influencer_content_fee.content_fee.io.deal
  end

  def team
    influencer_content_fee.team_name
  end

  def io_number
    io.io_number
  end

  def advertiser
    io.advertiser.name rescue EMPTY_LINE
  end

  def agency
    io.agency.name rescue EMPTY_LINE
  end

  def seller
    io.seller.collect {|seller| seller.first_name + " " + seller.last_name}.join(";")
  end

  def account_manager
    io.account_manager.collect {|account_manager| account_manager.first_name + " " + account_manager.last_name}.join(";")
  end

  def product
    content_fee.product.name rescue EMPTY_LINE
  end

  def total_budget
    "$" + (influencer_content_fee.content_fee.budget_loc || 0).round.to_s
  end

  def io_start_date
    io.start_date
  end

  def asset_date
    influencer_content_fee.effect_date
  end

  def influencer
    influencer_content_fee.influencer.name
  end

  def network
    influencer_content_fee.influencer.network_name
  end

  def fee_type
    influencer_content_fee.fee_type == "flat" ? "Flat" : "%"
  end

  def fee
    influencer_content_fee.fee_type == "flat" ? "$" + (influencer_content_fee.fee_amount || 0).to_s : (influencer_content_fee.fee_amount || 0).to_s + "%"
  end

  def gross_amount
    "$" + (influencer_content_fee.gross_amount_loc || 0).to_s
  end

  def net_amount
    "$" + (influencer_content_fee.net_loc || 0).to_s
  end

  def asset_link
    influencer_content_fee.asset
  end

  private

  attr_reader :influencer_content_fee
  attr_reader :content_fee
  attr_reader :io
  attr_reader :deal
end
