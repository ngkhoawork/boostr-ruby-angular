class Pmps::PmpDetailSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :name,
    :deal_id,
    :advertiser,
    :agency,
    :budget,
    :budget_loc,
    :currency,
    :budget_delivered,
    :budget_delivered_loc,
    :budget_remaining,
    :budget_remaining_loc,
    :start_date,
    :end_date,
    :pmp_items_cf_labels,
    :pmp_items_cf_types,
    :pmp_items_cf_keys
  )

  has_many :pmp_members, serializer: Pmps::PmpMemberSerializer
  has_many :pmp_items, serializer: Pmps::PmpItemSerializer

  def advertiser
    object.advertiser.serializable_hash(only: [:id, :name]) rescue nil
  end

  def pmp_items_cf
    object.pmp_items.map do |c|
      cf = c.custom_field
      cf&.attributes&.select do |key, _value|
        cf.allowed_attr_names.include?(key)
      end
    end.shift
  end

  def pmp_items_cf_keys
    ordered_cf_names&.map{|c|[(c.column_type + c.column_index.to_s)=>c&.disabled]}
  end

  def pmp_items_cf_labels
    ordered_cf_names&.map{|c|c&.field_label}&.uniq
  end

  def pmp_items_cf_types
    ordered_cf_names&.map{|c|c&.field_type}
  end

  def ordered_cf_names
    @_pmp_items_cf_keys ||= pmp_items_cf&.keys&.map{|key|find_cf_names(key)}&.sort_by {|obj| obj.position}
  end

  def parse_key(key)
    res = key.scan(/\d+|\D+/)
    if res.length.eql?(4)
      column_type = res[0..2].join
      index = res.last
    else
      column_type, index = key.scan(/\d+|\D+/)
    end
    return if column_type.blank? && index.blank?
    [column_type, index]
  end

  def find_cf_names(key)
    column_type, index = parse_key(key)
    object.company
                .custom_field_names
                .for_model('PmpItem')
                .find_by(column_type: column_type, column_index: index.to_i)
  end

  def agency
    object.agency.serializable_hash(only: [:id, :name]) rescue nil
  end

  def currency
    object.currency.serializable_hash(only: [:curr_cd, :curr_symbol]) rescue nil
  end
end
