class Forecast::PipelineDataSerializer < ActiveModel::Serializer
  attributes  :id, :name, :start_date, :end_date, :stage_id, :client_name,
              :agency_name, :probability, :budget, :in_period_amt, :in_period_split_amt, :wday_in_stage,
              :wday_since_opened, :wday_in_stage_color, :wday_since_opened_color, :in_period_split_weighted_amt

  def client_name
    object.advertiser.name rescue nil
  end

  def agency_name
    object.agency.name rescue nil
  end

  def probability
    stage.probability rescue nil
  end

  def total_budget
    deal_products.inject(0) do |sum, deal_product|
      sum + deal_product.budget
    end
  end

  def in_period_amt
    partial_amounts[:period_amt]
  end

  def in_period_split_amt
    partial_amounts[:split_period_amt]
  end

  def in_period_split_weighted_amt
    return nil unless probability && partial_amounts[:split_period_amt]
    probability * partial_amounts[:split_period_amt] / 100.0
  end

  def wday_in_stage
    object.wday_in_stage
  end

  def wday_since_opened
    object.wday_since_opened
  end

  def wday_in_stage_color
    if stage.red_threshold.present? or stage.yellow_threshold.present?
      if stage.red_threshold.present? and wday_in_stage >= stage.red_threshold
        'red'
      elsif stage.yellow_threshold.present? and wday_in_stage >= stage.yellow_threshold
        'yellow'
      else
        'green'
      end
    end
  end

  def wday_since_opened_color
    if company.red_threshold.present? || company.yellow_threshold.present?
      if company.red_threshold.present? && wday_since_opened >= company.red_threshold
        'red'
      elsif company.yellow_threshold.present? && wday_since_opened >= company.yellow_threshold
        'yellow'
      else
        'green'
      end
    end
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
    @_member_ids ||= if members.present?
      members.collect(&:id)
    end
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
