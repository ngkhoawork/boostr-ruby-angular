class Ios::IoSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :advertiser_id,
    :agency_id,
    :budget,
    :start_date,
    :end_date,
    :external_io_number,
    :io_number,
    :created_at,
    :updated_at,
    :name,
    :company_id,
    :deal_id,
    :budget_loc,
    :freezed,
    :curr_cd,
    :readable_months,
    :months,
    :days_per_month,
    :days,
    :currency,
    :print_items,
    :display_line_items
  )

  has_many :io_members, serializer: Ios::IoMemberSerializer
  has_many :content_fees, serializer: Ios::ContentFeeSerializer
  has_many :costs, serializer: Ios::CostSerializer
  has_many :influencer_content_fees, serializer: Ios::InfluencerContentFeeSerializer

  has_one :advertiser
  has_one :agency
  has_one :deal
end
