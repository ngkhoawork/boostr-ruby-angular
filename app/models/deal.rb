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

  def days
    (end_date - start_date).to_i
  end

  def add_product(product, total_budget)
    daily_budget = total_budget.to_f / days
    months.each_with_index do |month, index|
      monthly_budget = daily_budget * days_per_month[index]
      deal_products.create(product_id: product.id, period: Date.new(*month), budget: monthly_budget)
    end
  end

  def days_per_month
    array = []

    case months.length
      when 1
        array << days
      when 2
        array << (start_date.end_of_month - start_date).to_i
        array << (end_date - (end_date.beginning_of_month - 1)).to_i
      else
        array << (start_date.end_of_month - start_date).to_i
        months[1..-2].each do |month|
          array << Time.days_in_month(month[1], month[0])
        end
        array << (end_date - (end_date.beginning_of_month - 1)).to_i
    end
    array
  end
end
