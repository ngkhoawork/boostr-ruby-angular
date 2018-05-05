class CreateEalertTemplates < ActiveRecord::Migration
  def change
    create_table :ealert_templates do |t|
      t.references :company, foreign_key: true, null: false
      t.string :type
      t.string :recipients, array: true, default: []

      t.timestamps null: false
    end

    add_index :ealert_templates, [:company_id, :type], unique: true
  end
end
