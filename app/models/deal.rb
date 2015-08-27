class Deal < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :company
  belongs_to :advertiser, class_name: 'Client'
  belongs_to :agency, class_name: 'Client'
  belongs_to :stage, counter_cache: true
  belongs_to :creator, class_name: 'User', foreign_key: 'created_by'

  has_many :deal_products
  has_many :products, -> { distinct }, through: :deal_products

  validates :advertiser_id, :start_date, :end_date, :name, presence: true

  before_save do
    if deal_products.empty?
      self.budget = budget.to_i * 100 if budget_changed?
    end
  end

  after_update do
    reset_products if (start_date_changed? || end_date_changed?)
  end

  scope :for_client, -> client_id { where('advertiser_id = ? OR agency_id = ?', client_id, client_id) if client_id.present? }

  def as_json(options = {})
    super(options.merge(include: [:advertiser, :stage]))
  end

  def months
    (start_date..end_date).map { |d| [d.year, d.month] }.uniq
  end

  def days
    (end_date - start_date + 1).to_i
  end

  def add_product(product_id, total_budget, update_budget=true)
    daily_budget = total_budget.to_f / days
    months.each_with_index do |month, index|
      monthly_budget = daily_budget * days_per_month[index]
      deal_products.create(product_id: product_id, period: Date.new(*month), budget: monthly_budget.round(2) * 100)
    end
    update_total_budget if update_budget
  end

  def days_per_month
    array = []

    case months.length
    when 1
      array << days
    when 2
      array << ((start_date.end_of_month + 1) - start_date).to_i
      array << (end_date - (end_date.beginning_of_month - 1)).to_i
    else
      array << ((start_date.end_of_month + 1) - start_date).to_i
      months[1..-2].each do |month|
        array << Time.days_in_month(month[1], month[0])
      end
      array << (end_date - (end_date.beginning_of_month - 1)).to_i
    end
    array
  end

  def update_total_budget
    update_attributes(budget: deal_products.sum(:budget))
  end

  def reset_products
    array = []

    products.each do |product|
      old_deal_products = deal_products.where(product_id: product.id)

      total_budget = old_deal_products.sum(:budget) / 100
      old_deal_products.destroy_all
      array << {id: product.id, total_budget: total_budget}
    end

    array.each do |object|
      add_product(object[:id], object[:total_budget], false)
    end
  end


end
