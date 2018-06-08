class DealProductState
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: "deal_product_states"

  field :deal_id, type: Integer
  field :deal_products_sum, type: BigDecimal, default: 0
  field :previous_products_sum, type: BigDecimal, default: 0
  field :status,  type: Boolean, default: false
  field :event_type,  type: String
end
