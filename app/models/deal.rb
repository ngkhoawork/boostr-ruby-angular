class Deal < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :company
  belongs_to :advertiser, class_name: 'Client', foreign_key: 'advertiser_id', counter_cache: :advertiser_deals_count
  belongs_to :agency, class_name: 'Client', foreign_key: 'agency_id', counter_cache: :agency_deals_count
  belongs_to :stage, counter_cache: true
  belongs_to :creator, class_name: 'User', foreign_key: 'created_by'

  has_many :deal_products
  has_many :products, -> { distinct }, through: :deal_products
  has_many :deal_members
  has_many :users, through: :deal_members

  validates :advertiser_id, :start_date, :end_date, :name, presence: true

  before_save do
    if deal_products.empty?
      self.budget = budget.to_i * 100 if budget_changed?
    end
  end

  after_update do
    reset_products if (start_date_changed? || end_date_changed?)
  end

  after_create :generate_deal_members

  scope :for_client, -> client_id { where('advertiser_id = ? OR agency_id = ?', client_id, client_id) if client_id.present? }
  scope :for_time_period, -> time_period { where('start_date <= ? AND end_date >= ?', time_period.end_date, time_period.start_date) if time_period.present? }

  def as_json(options = {})
    super(options.merge(include: [:advertiser, :stage]))
  end

  def as_weighted_pipeline(time_period)
    {
      name: name,
      client_name: advertiser.name,
      probability: stage.probability,
      budget: budget,
      in_period_amt: in_period_amt(time_period),
      start_date: start_date
    }
  end

  def in_period_amt(time_period)
    deal_products.for_time_period(time_period).to_a.sum do |deal_product|
      from = [time_period.start_date, deal_product.start_date].max
      to = [time_period.end_date, deal_product.end_date].min
      num_days = (to.to_date - from.to_date) + 1
      deal_product.daily_budget * num_days
    end
  end

  def months
    (start_date..end_date).map { |d| [d.year, d.month] }.uniq
  end

  def days
    (end_date - start_date + 1).to_i
  end

  def add_product(product_id, total_budget, update_budget = true)
    daily_budget = total_budget.to_f / days
    months.each_with_index do |month, index|
      monthly_budget = daily_budget * days_per_month[index]
      period = Date.new(*month)
      deal_products.create(product_id: product_id, start_date: period, end_date: period.end_of_month, budget: monthly_budget.round(2) * 100)
    end
    update_total_budget if update_budget
  end

  def remove_product(product_id, update_budget = true)
    delete_product = products.find(product_id)
    products.delete(delete_product)
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
      array << { id: product.id, total_budget: total_budget }
    end

    array.each do |object|
      add_product(object[:id], object[:total_budget], false)
    end
  end

  def generate_deal_members
    advertiser.client_members.each do |client_member|
      deal_members.create(client_member.defaults)
    end
  end
end
