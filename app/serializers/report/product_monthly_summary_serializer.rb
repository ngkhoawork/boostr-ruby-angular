class Report::ProductMonthlySummarySerializer < ActiveModel::Serializer
  attributes  :record_type, :record_id, :id, :name, :advertiser, :agency, :holding_company, :budget, :budget_loc, :stage,
              :start_date, :end_date, :created_at, :closed_at, :type, :source, :members,
              :custom_fields, :currency, :product, :weighted_budget

  def record_type
    if is_deal
      'Deal'
    else
      'IO'
    end
  end

  def record_id
    row.id
  end

  def product
    product_row.product.serializable_hash(only: [:id, :name]) rescue nil
  end

  def name
    row.name
  end

  def members
    if is_deal
      members = row.deal_members.inject([]) do |data, obj|
        data << {
          id: obj.user_id,
          name: obj.user.name,
          share: obj.share
        }
      end
    else
      members = row.io_members.inject([]) do |data, obj|
        data << {
          id: obj.user_id,
          name: obj.user.name,
          share: obj.share
        }
      end
    end
    members
  end

  def advertiser
    row.advertiser.serializable_hash(only: [:id, :name]) rescue nil
  end

  def agency
    row.agency.serializable_hash(only: [:id, :name]) rescue nil
  end

  def holding_company
    row.agency.holding_company.name rescue nil
  end

  def stage
    if is_deal
      @_stage ||= row.stage.serializable_hash(only: [:name, :probability]) rescue nil
    else
      @_stage = {
        'name' => 'Revenue',
        'probability' => 100
      }
    end
    @_stage
  end

  def budget
    @_budget ||= row.budget.to_i
  end

  def budget_loc
    row.budget_loc.to_i
  end

  def weighted_budget
    stage['probability'].present? ? budget.to_f * stage['probability'].to_f / 100 : 0
  end

  def currency
    row.currency.serializable_hash(only: [:curr_symbol, :curr_cd])
  end

  def created_at
    row.created_at
  end

  def closed_at
    row.closed_at rescue nil
  end

  def start_date
    row.start_date
  end

  def end_date
    row.end_date
  end

  def type
    row.get_option_value_from_raw_fields(@options[:deal_custom_fields], 'Deal Type') rescue nil
  end

  def source
    row.get_option_value_from_raw_fields(@options[:deal_custom_fields], 'Deal Source') rescue nil
  end

  def custom_fields
    custom_fields = {}
    if is_deal && product_row && product_row.deal_product_cf.present?
      deal_product_cf_names.each do |deal_product_cf_name|
        field_name = deal_product_cf_name.field_type.to_s + deal_product_cf_name.field_index.to_s
        custom_fields[field_name] = product_row.deal_product_cf[field_name]
      end
    end
    custom_fields
  end

  private

  def object_classname
    @_object_classname = object.class.to_s
  end

  def is_deal
    @_is_deal ||= object_classname == 'DealProductBudget'
  end

  def row
    @_object ||= if is_deal
        object.deal
      else
        object.io
      end
  end

  def product_row
    @_product_row = case object_classname
      when 'DealProductBudget' then object.deal_product
      when 'ContentFeeProductBudget' then object.content_fee
      when 'DisplayLineItemBudget' then object.display_line_item
      end
  end

  def deal_product
    @_deal_product ||= object.deal_product rescue nil
  end

  def company
    @_company ||= object.deal.company
  end

  def deal_product_cf_names
    @_deal_product_cf_names ||= @options[:deal_product_cf_names]
  end
end
