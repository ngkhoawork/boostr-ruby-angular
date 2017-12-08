class IncreaseAccountCustomFieldLimit < ActiveRecord::Migration
  def change
    add_column :account_cfs, :currency8,       :decimal, precision: 15, scale: 2
    add_column :account_cfs, :currency9,       :decimal, precision: 15, scale: 2
    add_column :account_cfs, :currency10,      :decimal, precision: 15, scale: 2
    add_column :account_cfs, :currency_code8,  :string
    add_column :account_cfs, :currency_code9,  :string
    add_column :account_cfs, :currency_code10, :string
    add_column :account_cfs, :text6,           :string
    add_column :account_cfs, :text7,           :string
    add_column :account_cfs, :text8,           :string
    add_column :account_cfs, :text9,           :string
    add_column :account_cfs, :text10,          :string
    add_column :account_cfs, :note3,           :text
    add_column :account_cfs, :note4,           :text
    add_column :account_cfs, :note5,           :text
    add_column :account_cfs, :note6,           :text
    add_column :account_cfs, :note7,           :text
    add_column :account_cfs, :note8,           :text
    add_column :account_cfs, :note9,           :text
    add_column :account_cfs, :note10,          :text
    add_column :account_cfs, :datetime8,       :datetime
    add_column :account_cfs, :datetime9,       :datetime
    add_column :account_cfs, :datetime10,      :datetime
    add_column :account_cfs, :number8,         :decimal, precision: 15, scale: 2
    add_column :account_cfs, :number9,         :decimal, precision: 15, scale: 2
    add_column :account_cfs, :number10,        :decimal, precision: 15, scale: 2
    add_column :account_cfs, :integer8,        :decimal, precision: 15, scale: 0
    add_column :account_cfs, :integer9,        :decimal, precision: 15, scale: 0
    add_column :account_cfs, :integer10,       :decimal, precision: 15, scale: 0
    add_column :account_cfs, :boolean4,        :boolean
    add_column :account_cfs, :boolean5,        :boolean
    add_column :account_cfs, :boolean6,        :boolean
    add_column :account_cfs, :boolean7,        :boolean
    add_column :account_cfs, :boolean8,        :boolean
    add_column :account_cfs, :boolean9,        :boolean
    add_column :account_cfs, :boolean10,       :boolean
    add_column :account_cfs, :percentage6,     :decimal, precision: 5, scale: 2
    add_column :account_cfs, :percentage7,     :decimal, precision: 5, scale: 2
    add_column :account_cfs, :percentage8,     :decimal, precision: 5, scale: 2
    add_column :account_cfs, :percentage9,     :decimal, precision: 5, scale: 2
    add_column :account_cfs, :percentage10,    :decimal, precision: 5, scale: 2
    add_column :account_cfs, :dropdown8,       :string
    add_column :account_cfs, :dropdown9,       :string
    add_column :account_cfs, :dropdown10,      :string
    add_column :account_cfs, :number_4_dec8,   :decimal, precision: 15, scale: 4
    add_column :account_cfs, :number_4_dec9,   :decimal, precision: 15, scale: 4
    add_column :account_cfs, :number_4_dec10,  :decimal, precision: 15, scale: 4
  end
end
