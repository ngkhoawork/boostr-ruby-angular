class IncreaseDealCustomFieldLimit < ActiveRecord::Migration
  def change
    add_column :deal_custom_fields, :currency8,       :decimal, precision: 15, scale: 2
    add_column :deal_custom_fields, :currency9,       :decimal, precision: 15, scale: 2
    add_column :deal_custom_fields, :currency10,      :decimal, precision: 15, scale: 2
    add_column :deal_custom_fields, :currency_code8,  :string
    add_column :deal_custom_fields, :currency_code9,  :string
    add_column :deal_custom_fields, :currency_code10, :string
    add_column :deal_custom_fields, :text6,           :string
    add_column :deal_custom_fields, :text7,           :string
    add_column :deal_custom_fields, :text8,           :string
    add_column :deal_custom_fields, :text9,           :string
    add_column :deal_custom_fields, :text10,          :string
    add_column :deal_custom_fields, :note3,           :text
    add_column :deal_custom_fields, :note4,           :text
    add_column :deal_custom_fields, :note5,           :text
    add_column :deal_custom_fields, :note6,           :text
    add_column :deal_custom_fields, :note7,           :text
    add_column :deal_custom_fields, :note8,           :text
    add_column :deal_custom_fields, :note9,           :text
    add_column :deal_custom_fields, :note10,          :text
    add_column :deal_custom_fields, :datetime8,       :datetime
    add_column :deal_custom_fields, :datetime9,       :datetime
    add_column :deal_custom_fields, :datetime10,      :datetime
    add_column :deal_custom_fields, :number8,         :decimal, precision: 15, scale: 2
    add_column :deal_custom_fields, :number9,         :decimal, precision: 15, scale: 2
    add_column :deal_custom_fields, :number10,        :decimal, precision: 15, scale: 2
    add_column :deal_custom_fields, :integer8,        :decimal, precision: 15, scale: 0
    add_column :deal_custom_fields, :integer9,        :decimal, precision: 15, scale: 0
    add_column :deal_custom_fields, :integer10,       :decimal, precision: 15, scale: 0
    add_column :deal_custom_fields, :boolean4,        :boolean
    add_column :deal_custom_fields, :boolean5,        :boolean
    add_column :deal_custom_fields, :boolean6,        :boolean
    add_column :deal_custom_fields, :boolean7,        :boolean
    add_column :deal_custom_fields, :boolean8,        :boolean
    add_column :deal_custom_fields, :boolean9,        :boolean
    add_column :deal_custom_fields, :boolean10,       :boolean
    add_column :deal_custom_fields, :percentage6,     :decimal, precision: 5, scale: 2
    add_column :deal_custom_fields, :percentage7,     :decimal, precision: 5, scale: 2
    add_column :deal_custom_fields, :percentage8,     :decimal, precision: 5, scale: 2
    add_column :deal_custom_fields, :percentage9,     :decimal, precision: 5, scale: 2
    add_column :deal_custom_fields, :percentage10,    :decimal, precision: 5, scale: 2
    add_column :deal_custom_fields, :dropdown8,       :string
    add_column :deal_custom_fields, :dropdown9,       :string
    add_column :deal_custom_fields, :dropdown10,      :string
    add_column :deal_custom_fields, :sum8,            :integer
    add_column :deal_custom_fields, :sum9,            :integer
    add_column :deal_custom_fields, :sum10,           :integer
    add_column :deal_custom_fields, :number_4_dec8,   :decimal, precision: 15, scale: 4
    add_column :deal_custom_fields, :number_4_dec9,   :decimal, precision: 15, scale: 4
    add_column :deal_custom_fields, :number_4_dec10,  :decimal, precision: 15, scale: 4
    add_column :deal_custom_fields, :link8,           :string
    add_column :deal_custom_fields, :link9,           :string
    add_column :deal_custom_fields, :link10,          :string
  end
end
