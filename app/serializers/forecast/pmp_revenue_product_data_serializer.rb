class Forecast::PmpRevenueProductDataSerializer < ActiveModel::Serializer
  attributes  :id, :name, :agency,
              :advertiser, :budget, 
              :sum_period_budget, :split_period_budget,
              :start_date, :end_date,
              :products

  has_many :pmp_members, serializer: Pmps::PmpMemberSerializer

  def advertiser
    object.advertiser.name rescue nil
  end

  def agency
    object.agency.name rescue nil
  end

  def sum_period_budget
    partial_amounts[0]
  end

  def split_period_budget
    partial_amounts[1]
  end

  def products
    partial_amounts[2]
  end

  private

  def product_ids
    @_product_ids ||= @options[:product_ids]
  end

  def filter_start_date
    @_filter_start_date ||= @options[:filter_start_date]
  end

  def filter_end_date
    @_filter_end_date ||= @options[:filter_end_date]
  end

  def member_ids
    @_member_ids ||= @options[:member_ids]
  end

  def partial_amounts
    @_partial_amounts ||= Pmp::FilteredRevenueProductDataService
      .new(object, filter_start_date, filter_end_date, member_ids, product_ids)
      .perform
  end
end
