class InfluencerContentFee < ActiveRecord::Base
  belongs_to :influencer
  belongs_to :content_fee
  has_one :currency, class_name: 'Currency', primary_key: 'curr_cd', foreign_key: 'curr_cd'

  before_create do
    if gross_amount_loc_changed? || curr_cd_changed?
      update_net
      exchange_amount
    end
  end
  before_update do
    if gross_amount_loc_changed? || curr_cd_changed?
      update_net
      exchange_amount
    end
  end

  def update_net
    if influencer.agreement.present?
      fee_type = influencer.agreement.fee_type
      fee_amount = influencer.agreement.amount
      fee_amount_loc = (fee_amount || 0) * self.exchange_rate if self.exchange_rate
      if fee_type && fee_type == 'flat'
        self.net_loc = fee_amount_loc
      elsif fee_type && fee_type == 'percentage'
        self.net_loc = (fee_amount || 0) * self.gross_amount_loc / 100.0
      end
    end
  end

  def exchange_amount
    exchange_rate = self.exchange_rate
    if exchange_rate
      self.gross_amount = (self.gross_amount_loc.to_f / exchange_rate).round(2)
      self.net = (self.net_loc.to_f / exchange_rate).round(2)
    end
  end

  def exchange_rate
    self.influencer.company.exchange_rate_for(at_date: self.content_fee.io.created_at, currency: self.curr_cd)
  end
end
