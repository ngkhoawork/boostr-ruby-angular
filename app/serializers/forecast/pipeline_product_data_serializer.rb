class Forecast::PipelineProductDataSerializer < ActiveModel::Serializer
  attributes  :id, :name, :start_date, :end_date, :stage_id, :client_name,
              :agency_name, :probability, :budget, :in_period_amt, :wday_in_stage,
              :wday_since_opened, :wday_in_stage_color, :wday_since_opened_color

  def client_name
    object.advertiser.name rescue nil
  end

  def agency_name
    object.agency.name rescue nil
  end

  def probability
    stage.probability rescue nil
  end

  def budget
    if company.enable_net_forecasting
      margin_budget
    else
      total_budget
    end
  end

  def margin_budget
    deal_products.inject(0) do |sum, deal_product|
      sum + deal_product.budget * deal_product&.product&.margin / 100
    end
  end

  def total_budget
    deal_products.inject(0) do |sum, deal_product|
      sum + deal_product.budget
    end
  end

  def in_period_amt
    deal_products.inject(0) do |sum, deal_product|
      product = deal_product.product
      sum + deal_product.deal_product_budgets.inject(0) do |sum, deal_product_budget|
        from = [filter_start_date, deal_product_budget.start_date].max
        to = [filter_end_date, deal_product_budget.end_date].min
        num_days = [(to.to_date - from.to_date) + 1, 0].max
        if company.enable_net_forecasting
          sum += deal_product_budget.daily_budget.to_f * product.margin / 100 * num_days
        else
          sum += deal_product_budget.daily_budget.to_f * num_days
        end
        sum
      end
    end
  end

  def wday_in_stage
    object.wday_in_stage
  end

  def wday_since_opened
    object.wday_since_opened
  end

  def wday_in_stage_color
    if stage.red_threshold.present? || stage.yellow_threshold.present?
      if stage.red_threshold.present? && wday_in_stage >= stage.red_threshold
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

  def stage
    @_stage ||= object.stage
  end

  def company
    @_company ||= object.company
  end
end
