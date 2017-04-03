class CreateDealProductCfs < ActiveRecord::Migration
  def change
    create_table :deal_product_cfs do |t|
      t.belongs_to :company, index: true, foreign_key: true
      t.belongs_to :deal, index: true, foreign_key: true
      t.decimal :currency1
      t.decimal :currency2
      t.decimal :currency3
      t.decimal :currency4
      t.decimal :currency5
      t.decimal :currency6
      t.decimal :currency7
      t.string :currency_code1
      t.string :currency_code2
      t.string :currency_code3
      t.string :currency_code4
      t.string :currency_code5
      t.string :currency_code6
      t.string :currency_code7
      t.string :text1
      t.string :text2
      t.string :text3
      t.string :text4
      t.string :text5
      t.text :note1
      t.text :note2
      t.datetime :datetime1
      t.datetime :datetime2
      t.datetime :datetime3
      t.datetime :datetime4
      t.datetime :datetime5
      t.datetime :datetime6
      t.datetime :datetime7
      t.decimal :number1
      t.decimal :number2
      t.decimal :number3
      t.decimal :number4
      t.decimal :number5
      t.decimal :number6
      t.decimal :number7
      t.decimal :integer1
      t.decimal :integer2
      t.decimal :integer3
      t.decimal :integer4
      t.decimal :integer5
      t.decimal :integer6
      t.decimal :integer7
      t.boolean :boolean1
      t.boolean :boolean2
      t.boolean :boolean3
      t.decimal :percentage1
      t.decimal :percentage2
      t.decimal :percentage3
      t.decimal :percentage4
      t.decimal :percentage5
      t.string :dropdown1
      t.string :dropdown2
      t.string :dropdown3
      t.string :dropdown4
      t.string :dropdown5
      t.string :dropdown6
      t.string :dropdown7
      t.integer :sum1
      t.integer :sum2
      t.integer :sum3
      t.integer :sum4
      t.integer :sum5
      t.integer :sum6
      t.integer :sum7

      t.timestamps null: false
    end
  end
end
