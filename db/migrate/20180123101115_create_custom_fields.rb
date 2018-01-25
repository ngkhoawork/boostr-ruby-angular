class CreateCustomFields < ActiveRecord::Migration
  def change
    create_table :custom_fields do |t|
      t.belongs_to :company, index: true, foreign_key: true
      t.references :subject, polymorphic: true

      t.decimal :currency1, precision: 15, scale: 2
      t.decimal :currency2, precision: 15, scale: 2
      t.decimal :currency3, precision: 15, scale: 2
      t.decimal :currency4, precision: 15, scale: 2
      t.decimal :currency5, precision: 15, scale: 2
      t.decimal :currency6, precision: 15, scale: 2
      t.decimal :currency7, precision: 15, scale: 2
      t.decimal :currency8, precision: 15, scale: 2
      t.decimal :currency9, precision: 15, scale: 2
      t.decimal :currency10, precision: 15, scale: 2

      t.string :currency_code1
      t.string :currency_code2
      t.string :currency_code3
      t.string :currency_code4
      t.string :currency_code5
      t.string :currency_code6
      t.string :currency_code7
      t.string :currency_code8
      t.string :currency_code9
      t.string :currency_code10

      t.string :text1
      t.string :text2
      t.string :text3
      t.string :text4
      t.string :text5
      t.string :text6
      t.string :text7
      t.string :text8
      t.string :text9
      t.string :text10

      t.text :note1
      t.text :note2
      t.text :note3
      t.text :note4
      t.text :note5
      t.text :note6
      t.text :note7
      t.text :note8
      t.text :note9
      t.text :note10

      t.datetime :datetime1
      t.datetime :datetime2
      t.datetime :datetime3
      t.datetime :datetime4
      t.datetime :datetime5
      t.datetime :datetime6
      t.datetime :datetime7
      t.datetime :datetime8
      t.datetime :datetime9
      t.datetime :datetime10

      t.decimal :number1, precision: 15, scale: 2
      t.decimal :number2, precision: 15, scale: 2
      t.decimal :number3, precision: 15, scale: 2
      t.decimal :number4, precision: 15, scale: 2
      t.decimal :number5, precision: 15, scale: 2
      t.decimal :number6, precision: 15, scale: 2
      t.decimal :number7, precision: 15, scale: 2
      t.decimal :number8, precision: 15, scale: 2
      t.decimal :number9, precision: 15, scale: 2
      t.decimal :number10, precision: 15, scale: 2

      t.decimal :integer1, precision: 15, scale: 0
      t.decimal :integer2, precision: 15, scale: 0
      t.decimal :integer3, precision: 15, scale: 0
      t.decimal :integer4, precision: 15, scale: 0
      t.decimal :integer5, precision: 15, scale: 0
      t.decimal :integer6, precision: 15, scale: 0
      t.decimal :integer7, precision: 15, scale: 0
      t.decimal :integer8, precision: 15, scale: 0
      t.decimal :integer9, precision: 15, scale: 0
      t.decimal :integer10, precision: 15, scale: 0

      t.boolean :boolean1
      t.boolean :boolean2
      t.boolean :boolean3
      t.boolean :boolean4
      t.boolean :boolean5
      t.boolean :boolean6
      t.boolean :boolean7
      t.boolean :boolean8
      t.boolean :boolean9
      t.boolean :boolean10

      t.decimal :percentage1, precision: 5, scale: 2
      t.decimal :percentage2, precision: 5, scale: 2
      t.decimal :percentage3, precision: 5, scale: 2
      t.decimal :percentage4, precision: 5, scale: 2
      t.decimal :percentage5, precision: 5, scale: 2
      t.decimal :percentage6, precision: 5, scale: 2
      t.decimal :percentage7, precision: 5, scale: 2
      t.decimal :percentage8, precision: 5, scale: 2
      t.decimal :percentage9, precision: 5, scale: 2
      t.decimal :percentage10, precision: 5, scale: 2

      t.string  :dropdown1
      t.string  :dropdown2
      t.string  :dropdown3
      t.string  :dropdown4
      t.string  :dropdown5
      t.string  :dropdown6
      t.string  :dropdown7
      t.string  :dropdown8
      t.string  :dropdown9
      t.string  :dropdown10

      t.integer  :sum1
      t.integer  :sum2
      t.integer  :sum3
      t.integer  :sum4
      t.integer  :sum5
      t.integer  :sum6
      t.integer  :sum7
      t.integer  :sum8
      t.integer  :sum9
      t.integer  :sum10

      t.decimal  :number_4_dec1,   precision: 15, scale: 4
      t.decimal  :number_4_dec2,   precision: 15, scale: 4
      t.decimal  :number_4_dec3,   precision: 15, scale: 4
      t.decimal  :number_4_dec4,   precision: 15, scale: 4
      t.decimal  :number_4_dec5,   precision: 15, scale: 4
      t.decimal  :number_4_dec6,   precision: 15, scale: 4
      t.decimal  :number_4_dec7,   precision: 15, scale: 4
      t.decimal  :number_4_dec8,   precision: 15, scale: 4
      t.decimal  :number_4_dec9,   precision: 15, scale: 4
      t.decimal  :number_4_dec10,  precision: 15, scale: 4

      t.string   :link1
      t.string   :link2
      t.string   :link3
      t.string   :link4
      t.string   :link5
      t.string   :link6
      t.string   :link7
      t.string   :link8
      t.string   :link9
      t.string   :link10

      t.timestamps null: false
    end

    add_index :custom_fields, [:subject_type, :subject_id], unique: true
  end
end
