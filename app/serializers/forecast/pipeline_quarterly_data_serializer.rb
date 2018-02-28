class Forecast::PipelineQuarterlyDataSerializer < ActiveModel::Serializer
  attributes  :id, :name, :start_date, :end_date, :stage_id,
              :budget, :in_period_amt, :split_period_budget,
              :month_amounts, :quarter_amounts

  has_one :advertiser, serializer: Deals::AdvertiserSerializer
  has_one :agency, serializer: Deals::AgencySerializer
  has_one :stage, serializer: Deals::StageSerializer
  has_many :deal_members, serializer: Deals::DealMemberSerializer

  def total_budget
    deal_products.inject(0) do |sum, deal_product|
      sum + deal_product.budget
    end
  end

  def in_period_amt
    partial_amounts[0]
  end

  def split_period_budget
    partial_amounts[1]
  end

  def month_amounts
    partial_amounts[2]
  end

  def quarter_amounts
    partial_amounts[3]
  end

  private

  def company
    @_company ||= object.company
  end

  def deal_products
    @_deal_products ||= object.deal_products.inject([]) do |result, deal_product|
      if deal_product.open == true && (product_ids.nil? || product_ids.include?(deal_product.product_id))
        result << deal_product
      end
      result
    end
  end

  def product_ids
    @_product_ids ||= if products.present?
      products.collect(&:id)
    end
  end

  def filter_start_date
    @_filter_start_date ||= @options[:filter_start_date]
  end

  def filter_end_date
    @_filter_end_date ||= @options[:filter_end_date]
  end

  def products
    @_products ||= @options[:products]
  end

  def members
    @_members ||= @options[:members]
  end

  def member_ids
    @_member_ids ||= members.collect(&:id)
  end

  def deal_users
    @_deal_users ||= object.deal_members
      .select{ |deal_member| member_ids.nil? || member_ids.include?(deal_member.user_id) }
  end

  def is_net_forecast
    @_is_net_forecast ||= @options[:is_net_forecast]
  end

  def stage
    @_stage ||= object.stage
  end

  def company
    @_company ||= object.company
  end

  def partial_amounts
    @_partial_amounts ||= Deal::FilteredPipelineDataService
      .new(
        object,
        filter_start_date,
        filter_end_date,
        member_ids,
        product_ids,
        is_net_forecast
      ).perform
  end
end
