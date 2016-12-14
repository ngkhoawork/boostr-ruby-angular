class CreateStarSchemaTables < ActiveRecord::Migration
  def change
    create_table :account_dimensions do |t|
      t.string :name
      t.integer :account_type
      t.integer :category_id
      t.integer :subcategory_id
    end

    create_table :time_dimensions do |t|
      t.string :name
      t.date :start_date
      t.date :end_date
      t.integer :days_length
    end

    create_table :account_revenue_facts do |t|
      t.belongs_to :company, index: true, foreign_key: true
      t.belongs_to :account_dimension, index: true, foreign_key: true
      t.belongs_to :time_dimension, index: true, foreign_key: true
      t.integer :category_id
      t.integer :subcategory_id
      t.integer :revenue_amount
    end

    create_table :account_pipeline_facts do |t|
      t.belongs_to :company, index: true, foreign_key: true
      t.belongs_to :account_dimension, index: true, foreign_key: true
      t.belongs_to :time_dimension, index: true, foreign_key: true
      t.integer :category_id
      t.integer :subcategory_id
      t.integer :pipeline_amount
    end

    reversible do |directive|
      directive.up do
        create_default_time_periods
        populate_account_dimensions
      end
    end
  end

  def create_default_time_periods
    (2013..2017).each do |year|
      start_date = Date.new(year, 1, 1)
      end_date = (start_date >> 12) - 1

      TimeDimension.create(
        name: "#{year}",
        start_date: start_date,
        end_date: end_date,
        days_length: (end_date.yday - start_date.yday) + 1
      )

      quarter_hashes.each do |quarter_hash|
        start_date = Date.new(year, quarter_hash[:starting_month], 1)
        end_date = (start_date >> 3) - 1

        TimeDimension.create(
          name: quarter_hash[:quarter_name] + " #{year}",
          start_date: start_date,
          end_date: end_date,
          days_length: (end_date.yday - start_date.yday) + 1
        )
      end

      (1..12).each do |month|
        start_date = Date.new(year, month, 1)
        end_date = Date.new(year, month, -1)

        TimeDimension.create(
          name: Date::MONTHNAMES[month] + " #{year}",
          start_date: start_date,
          end_date: end_date,
          days_length: end_date.day
        )
      end
    end
  end

  def populate_account_dimensions
    accounts = Client.all
    accounts.each do |account|
      AccountDimension.create(
        id: account.id,
        name: account.name,
        account_type: account.global_type_id,
        category_id: account.client_category_id,
        subcategory_id: account.client_subcategory_id
      )
    end
  end

  def quarter_hashes
    [
      {starting_month: 1, quarter_name: "Q1"},
      {starting_month: 4, quarter_name: "Q2"},
      {starting_month: 7, quarter_name: "Q3"},
      {starting_month: 10, quarter_name: "Q4"}
    ]
  end
end
