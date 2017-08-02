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
  scope :by_effect_date, -> (start_date, end_date) do
    where(effect_date: start_date..end_date) if start_date.present? && end_date.present?
  end

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

  def team_name
    team = nil
    if content_fee.io.highest_member.present? 
      user = content_fee.io.highest_member.user
      if user && user.leader?
        team = user.teams.first
      elsif user
        team = user.team
      end
    end
    if team
      team.name
    else
      ''
    end
  end

  def self.to_csv(influencer_content_fees)
    Csv::InfluencerBudgetDetailService.new(influencer_content_fees).perform
  end
end
