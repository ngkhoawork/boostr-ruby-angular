require 'rubygems'
require 'zip'

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

  has_many :values, as: :subject

  validates :advertiser_id, :start_date, :end_date, :name, :stage_id, presence: true

  accepts_nested_attributes_for :values, reject_if: proc { |attributes| attributes['option_id'].blank? }

  before_save do
    if deal_products.empty?
      self.budget = budget.to_i * 100 if budget_changed?
    end
  end

  after_update do
    reset_products if (start_date_changed? || end_date_changed?)
  end

  after_create :generate_deal_members

  scope :for_client, -> (client_id) { where('advertiser_id = ? OR agency_id = ?', client_id, client_id) if client_id.present? }
  scope :for_time_period, -> (start_date, end_date) { where('deals.start_date <= ? AND deals.end_date >= ?', end_date, start_date) }
  scope :open, -> { joins(:stage).where('stages.open IS true') }

  def fields
    company.fields.where(subject_type: self.class.name)
  end

  def as_json(options = {})
    super(options.merge(include: [:advertiser, :stage, :values]))
  end

  def as_weighted_pipeline(start_date, end_date)
    {
      name: name,
      client_name: advertiser.name,
      probability: stage.probability,
      budget: budget,
      in_period_amt: in_period_amt(start_date, end_date),
      start_date: self.start_date
    }
  end

  def in_period_amt(start_date, end_date)
    deal_products.for_time_period(start_date, end_date).to_a.sum do |deal_product|
      from = [start_date, deal_product.start_date].max
      to = [end_date, deal_product.end_date].min
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
    when 0
      array
    when 1
      array << days
    when 2
      array << ((start_date.end_of_month + 1) - start_date).to_i
      array << (end_date - (end_date.beginning_of_month - 1)).to_i
    else
      array << ((start_date.end_of_month + 1) - start_date).to_i
      (months[1..-2] || []).each do |month|
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
    # This only happens if start_date or end_date has changed on the Deal and thus it has already be touched
    ActiveRecord::Base.no_touching do
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
  end

  def generate_deal_members
    # This only gets called on create where the Deal has inherently been touched
    ActiveRecord::Base.no_touching do
      advertiser.client_members.each do |client_member|
        deal_member = deal_members.create(client_member.defaults)

        if client_member.role_value_defaults
          deal_member.values.create(client_member.role_value_defaults)
        end
      end
    end
  end

  def self.to_zip

    deals_csv = CSV.generate do |csv|
      csv << ["Deal ID", "Name", "Advertiser", "Agency", "Team Member", "Budget", "Stage", "Probability", "Start Date", "End Date"]
      all.each do |deal|
        agency_name = deal.agency.present? ? deal.agency.name : nil
        first_member = deal.deal_members.order("created_at").first
		first_member_name = first_member.present? ? first_member.user.name : nil
        csv << [deal.id, deal.name, deal.advertiser.name, agency_name, first_member_name, deal.budget/100.0, deal.stage.name, deal.stage.probability, deal.start_date, deal.end_date]
      end
    end

    products_csv = CSV.generate do |csv|
      csv << ["Deal ID", "Name", "Product", "Budget", "Period"]
      all.each do |deal|
        deal.deal_products.each do |product|
          product_name = product.product.present? ? product.product.name : nil
		  csv << [deal.id, deal.name, product_name, product.budget/100.0, product.start_date.strftime("%B %Y")]
        end
      end
    end

    filestream = Zip::OutputStream.write_buffer do |zio|
      zio.put_next_entry("deals-#{Date.today}.csv")
      zio.write deals_csv
      zio.put_next_entry("products-#{Date.today}.csv")
      zio.write products_csv
    end
    filestream.rewind
	filestream.read

  end

end
