class DealProductBudget < ActiveRecord::Base
  # belongs_to :deal, touch: true
  # belongs_to :product
  belongs_to :deal_product
  delegate :deal, to: :deal_product

  scope :for_time_period, -> (start_date, end_date) { where('deal_product_budgets.start_date <= ? AND deal_product_budgets.end_date >= ?', end_date, start_date) }

  validates :start_date, :end_date, presence: true

  def daily_budget
    budget / (end_date - start_date + 1).to_f
  end

  def self.to_csv(company_id)
    header = [
      :Deal_Id,
      :Deal_Name,
      :Deal_Percentage,
      :Advertiser,
      :Product,
      :Budget,
      :Start_Date,
      :End_Date,
    ]

    CSV.generate(headers: true) do |csv|
      csv << header

      deals = Deal.where(company_id: company_id)
      .includes(:products, :deal_products, :deal_product_budgets, :stage, :advertiser)
      .order(:id)

      deals.each do |deal|
        deal.deal_products.each do |deal_product|
          deal_product.deal_product_budgets.each do |dpb|
            line = []
            line << deal.id
            line << deal.name
            line << deal.stage.probability
            line << deal.advertiser.name
            line << deal_product.product.name
            line << dpb.budget
            line << dpb.start_date
            line << dpb.end_date

            csv << line
          end
        end
      end
    end
  end

  def self.import(file, current_user)
    errors = []
    row_number = 0

    CSV.parse(file, headers: true) do |row|
      row_number += 1

      if row[0]
        begin
          deal = current_user.company.deals.find(row[0].strip)
        rescue ActiveRecord::RecordNotFound
          error = { row: row_number, message: ["Deal ID #{row[0]} could not be found"] }
          errors << error
          next
        end
      end

      if row[1]
        if !(deal)
          deals = current_user.company.deals.where('name ilike ?', row[1].strip)
          if deals.length > 1
            error = { row: row_number, message: ["Deal Name #{row[1]} matched more than one deal record"] }
            errors << error
            next
          elsif deals.length < 1
            error = { row: row_number, message: ["Deal Name #{row[1]} did not match any Deal record"] }
            errors << error
            next
          end
          deal = deals.first
        end
      else
        error = { row: row_number, message: ["Deal Name can't be blank"] }
        errors << error
        next
      end

      if row[2]
        product = current_user.company.products.where(name: row[2]).first
        unless product
          error = { row: row_number, message: ["Product #{row[2]} could not be found"] }
          errors << error
          next
        end
      else
        error = { row: row_number, message: ["Deal Product can't be blank"] }
        errors << error
        next
      end

      if row[3]
        unless budget = Float(row[3].strip) rescue false
          error = { row: row_number, message: ["Budget must be a numeric value"] }
          errors << error
          next
        end
      else
        error = { row: row_number, message: ["Budget can't be blank"] }
        errors << error
        next
      end

      if row[4]
        begin
          period = Date.strptime(row[4].strip, '%b-%y')
        rescue ArgumentError
          error = {row: row_number, message: ['Period must be in valid format: Mon-YY'] }
          errors << error
          next
        end

        unless period.between?(deal.start_date.beginning_of_month, deal.end_date.end_of_month)
          error = { row: row_number, message: ["Period #{row[4]} must be within Deal Period"] }
          errors << error
          next
        end
      else
        error = { row: row_number, message: ["Period can't be blank"] }
        errors << error
        next
      end

      deal_product_budget_params = {
        budget: budget,
        start_date: period.beginning_of_month,
        end_date: period.end_of_month
      }

      deal_product = deal.deal_products.where(product: product).first

      if !(deal_product)
        deal_product = deal.deal_products.new(product: product)
        deal_product_is_new = true
      else
        deal_product_budget_params[:deal_product_id] = deal_product.id

        if deal_product.deal_product_budgets.count >= deal.months.length
          error = { row: row_number, message: ["Deal Product #{row[2].strip} already exists"] }
          errors << error
          next
        end

        if deal_product.deal_product_budgets.where(start_date: period.beginning_of_month).any?
          error = { row: row_number, message: ["Deal Product Budget for #{row[4]} month already exists"] }
          errors << error
          next
        end
      end

      if deal_product.update_attributes(deal_product_budgets_attributes: [deal_product_budget_params])
        deal_product.update_budget if deal_product_is_new
        deal_product.deal.update_total_budget if deal_product_is_new
      else
        error = { row: row_number, message: deal_product.errors.full_messages }
        errors << error
        next
      end
    end

    errors
  end
end
