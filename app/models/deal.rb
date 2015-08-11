class Deal < ActiveRecord::Base
  belongs_to :company
  belongs_to :advertiser, class_name: 'Client'
  belongs_to :agency, class_name: 'Client'
  belongs_to :stage, counter_cache: true
  belongs_to :creator, class_name: 'User', foreign_key: 'created_by'

  has_many :deal_products
  has_many :products, -> { distinct }, through: :deal_products

  validates :advertiser_id, :start_date, :end_date, :name, presence: true

  def as_json(options = {})
    super(options.merge(include: [:advertiser, :stage]))
  end

  def months
    (start_date..end_date).map {|d| [d.year, d.month]}.uniq
  end

  def add_product(product, total_budget)
    budget = total_budget.to_i / months.length
    months.each do |month|
      deal_products.create(product_id: product.id, period: Date.new(*month), budget: budget)
    end
  end
end
