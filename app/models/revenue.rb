class Revenue < ActiveRecord::Base
  belongs_to :company
  belongs_to :client
  belongs_to :user
  belongs_to :product

  validates :company_id, :order_number, :line_number, :ad_server, presence: true

  before_save :set_daily_budget

  def self.import(file, company_id)
    errors = []
    row_number = 0
    CSV.parse(file, headers: true) do |row|
      row_number += 1

      unless user = User.where(email: row[14], company_id: company_id).first
        error = { row: row_number, message: ['Sales Rep could not be found'] }
        errors << error
        next
      end

      unless client = Client.where(id: row[13], company_id: company_id).first
        error = { row: row_number, message: ['Client could not be found'] }
        errors << error
        next
      end

      unless product = Product.where(id: row[15], company_id: company_id).first
        error = { row: row_number, message: ['Product could not be found'] }
        errors << error
        next
      end

      find_params = {
        company_id: company_id,
        order_number: row[0],
        line_number: row[1],
        ad_server: row[2]
      }

      create_params = {
        quantity: row[3].to_i,
        price: row[4].to_f * 100,
        price_type: row[5],
        delivered: row[6].to_i,
        remaining: row[7].to_i,
        budget: row[8].to_i,
        budget_remaining: row[9].to_i,
        start_date: DateTime.strptime(row[10], '%m/%d/%Y'),
        end_date: DateTime.strptime(row[11], '%m/%d/%Y'),
        client_id: client.id,
        user_id: user.id,
        product_id: product.id
      }

      revenue = Revenue.find_or_initialize_by(find_params)
      unless revenue.update_attributes(create_params)
        error = { row: row_number, message: revenue.errors.full_messages }
        errors << error
      end
    end
    errors
  end

  def client_name
    client.name if client.present?
  end

  def user_name
    user.name if user.present?
  end

  def product_name
    product.name if product.present?
  end

  def set_daily_budget
    self.daily_budget = budget.to_f / (end_date.to_date - start_date.to_date + 1) * 100
  end

  def daily_budget
    read_attribute(:daily_budget)/100.0
  end

  def as_json(options = {})
    super(options.merge(methods: [:client_name, :user_name, :product_name]))
  end
end
