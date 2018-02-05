class CreateCustomFields < ActiveRecord::Migration
  def change
    create_table :custom_fields do |t|
      t.belongs_to :company, index: true, foreign_key: true
      t.references :subject, polymorphic: true

      t.decimal :decimal1, precision: 15, scale: 2
      t.decimal :decimal2, precision: 15, scale: 2
      t.decimal :decimal3, precision: 15, scale: 2
      t.decimal :decimal4, precision: 15, scale: 2
      t.decimal :decimal5, precision: 15, scale: 2
      t.decimal :decimal6, precision: 15, scale: 2
      t.decimal :decimal7, precision: 15, scale: 2
      t.decimal :decimal8, precision: 15, scale: 2
      t.decimal :decimal9, precision: 15, scale: 2
      t.decimal :decimal10, precision: 15, scale: 2
      t.decimal :decimal11, precision: 15, scale: 2
      t.decimal :decimal12, precision: 15, scale: 2
      t.decimal :decimal13, precision: 15, scale: 2
      t.decimal :decimal14, precision: 15, scale: 2
      t.decimal :decimal15, precision: 15, scale: 2
      t.decimal :decimal16, precision: 15, scale: 2
      t.decimal :decimal17, precision: 15, scale: 2
      t.decimal :decimal18, precision: 15, scale: 2
      t.decimal :decimal19, precision: 15, scale: 2
      t.decimal :decimal20, precision: 15, scale: 2
      t.decimal :decimal21, precision: 15, scale: 2
      t.decimal :decimal22, precision: 15, scale: 2
      t.decimal :decimal23, precision: 15, scale: 2
      t.decimal :decimal24, precision: 15, scale: 2
      t.decimal :decimal25, precision: 15, scale: 2
      t.decimal :decimal26, precision: 15, scale: 2
      t.decimal :decimal27, precision: 15, scale: 2
      t.decimal :decimal28, precision: 15, scale: 2
      t.decimal :decimal29, precision: 15, scale: 2
      t.decimal :decimal30, precision: 15, scale: 2
      t.decimal :decimal31, precision: 15, scale: 2
      t.decimal :decimal32, precision: 15, scale: 2
      t.decimal :decimal33, precision: 15, scale: 2
      t.decimal :decimal34, precision: 15, scale: 2
      t.decimal :decimal35, precision: 15, scale: 2
      t.decimal :decimal36, precision: 15, scale: 2
      t.decimal :decimal37, precision: 15, scale: 2
      t.decimal :decimal38, precision: 15, scale: 2
      t.decimal :decimal39, precision: 15, scale: 2
      t.decimal :decimal40, precision: 15, scale: 2

      t.string :string1
      t.string :string2
      t.string :string3
      t.string :string4
      t.string :string5
      t.string :string6
      t.string :string7
      t.string :string8
      t.string :string9
      t.string :string10
      t.string :string11
      t.string :string12
      t.string :string13
      t.string :string14
      t.string :string15
      t.string :string16
      t.string :string17
      t.string :string18
      t.string :string19
      t.string :string20
      t.string :string21
      t.string :string22
      t.string :string23
      t.string :string24
      t.string :string25
      t.string :string26
      t.string :string27
      t.string :string28
      t.string :string29
      t.string :string30
      t.string :string31
      t.string :string32
      t.string :string33
      t.string :string34
      t.string :string35
      t.string :string36
      t.string :string37
      t.string :string38
      t.string :string39
      t.string :string40

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

      t.integer :integer1
      t.integer :integer2
      t.integer :integer3
      t.integer :integer4
      t.integer :integer5
      t.integer :integer6
      t.integer :integer7
      t.integer :integer8
      t.integer :integer9
      t.integer :integer10
      t.integer :integer11
      t.integer :integer12
      t.integer :integer13
      t.integer :integer14
      t.integer :integer15
      t.integer :integer16
      t.integer :integer17
      t.integer :integer18
      t.integer :integer19
      t.integer :integer20

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
      t.boolean :boolean11
      t.boolean :boolean12
      t.boolean :boolean13
      t.boolean :boolean14
      t.boolean :boolean15
      t.boolean :boolean16
      t.boolean :boolean17
      t.boolean :boolean18
      t.boolean :boolean19
      t.boolean :boolean20

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

      t.timestamps null: false
    end

    add_index :custom_fields, [:subject_type, :subject_id], unique: true

    (1..40).each do |field_index|
      add_index :custom_fields, "decimal#{field_index}", where: "decimal#{field_index} IS NOT NULL"
    end

    (1..40).each do |field_index|
      add_index :custom_fields, "string#{field_index}", where: "string#{field_index} IS NOT NULL"
    end

    (1..10).each do |field_index|
      add_index :custom_fields, "datetime#{field_index}", where: "datetime#{field_index} IS NOT NULL"
    end

    (1..20).each do |field_index|
      add_index :custom_fields, "integer#{field_index}", where: "integer#{field_index} IS NOT NULL"
    end

    (1..20).each do |field_index|
      add_index :custom_fields, "boolean#{field_index}", where: "boolean#{field_index} IS NOT NULL"
    end

    (1..10).each do |field_index|
      add_index :custom_fields, "number_4_dec#{field_index}", where: "number_4_dec#{field_index} IS NOT NULL"
    end
  end
end
