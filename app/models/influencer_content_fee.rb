class InfluencerContentFee < ActiveRecord::Base
  belongs_to :influencer
  belongs_to :content_fee
  has_one :currency, class_name: 'Currency', primary_key: 'curr_cd', foreign_key: 'curr_cd'

  before_create do
    update_net
    exchange_amount
  end
  before_update do
    update_net
    exchange_amount
  end

  scope :for_influencer_id, -> (influencer_id) { where(influencer_id: influencer_id) if influencer_id.present? }

  def update_net
    if influencer.agreement.present?
      fee_amount = self.fee_amount
      fee_amount_loc = (fee_amount || 0) / self.exchange_rate if self.exchange_rate && self.fee_type == 'flat'
      if self.fee_type && self.fee_type == 'flat'
        self.net_loc = fee_amount_loc
      elsif self.fee_type && self.fee_type == 'percentage'
        self.net_loc = (fee_amount || 0) * self.gross_amount_loc / 100.0
      end
    end
  end

  def exchange_amount
    exchange_rate = self.exchange_rate
    if exchange_rate
      self.gross_amount = (self.gross_amount_loc.to_f * exchange_rate).round(2)
      self.net = (self.net_loc.to_f * exchange_rate).round(2)
      self.fee_amount_loc = (self.fee_amount.to_f / exchange_rate).round(2) if self.fee_type == 'flat'
    end
  end

  def exchange_rate
    self.influencer.company.exchange_rate_for(at_date: self.content_fee.io.created_at, currency: self.curr_cd)
  end

  def self.to_csv(influencer_content_fees, company)
    CSV.generate do |csv|
      header = []
      header << "Team"
      header << "IO Number"
      header << "Advertiser"
      header << "Agency"
      header << 'Seller'
      header << "Account Manager"
      header << "Product"
      header << "Total Budget"
      header << "IO Start Date"
      header << "Asset Date"
      header << "Influencer"
      header << "Network"
      header << "Fee Type"
      header << "Fee"
      header << "Gross Amount"
      header << "Net Amount"
      header << "Asset Link"

      csv << header
      influencer_content_fees.each do |influencer_content_fee|
        io = influencer_content_fee.content_fee.io
        deal = influencer_content_fee.content_fee.io.deal
        line = [
          deal.deal_members.collect {|deal_member| deal_member.username.first_name + " " + deal_member.username.last_name + " (" + deal_member.share.to_s + "%)"}.join(";"),
          io.io_number,
          deal.advertiser ? deal.advertiser.name : nil,
          deal.agency ? deal.agency.name : nil,
          deal.seller.collect {|seller| seller.first_name + " " + seller.last_name}.join(";"),
          deal.account_manager.collect {|account_manager| account_manager.first_name + " " + account_manager.last_name}.join(";"),
          influencer_content_fee.content_fee.product.name,
          "$" + (influencer_content_fee.content_fee.budget_loc || 0).to_s,
          io.start_date,
          influencer_content_fee.effect_date,
          influencer_content_fee.influencer.name,
          influencer_content_fee.influencer.network_name,
          influencer_content_fee.fee_type == "flat" ? "Flat" : "Percentage",
          influencer_content_fee.fee_type == "flat" ? "$" + (influencer_content_fee.fee_amount || 0).to_s : (influencer_content_fee.fee_amount || 0).to_s + "%",
          "$" + (influencer_content_fee.gross_amount_loc || 0).to_s,
          "$" + (influencer_content_fee.net_loc || 0).to_s,
          influencer_content_fee.asset
        ]
        csv << line
      end
    end
  end
end
