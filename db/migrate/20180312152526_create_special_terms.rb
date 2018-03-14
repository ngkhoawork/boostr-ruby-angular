class CreateSpecialTerms < ActiveRecord::Migration
  def change
    create_table :special_terms do |t|
      t.references :contract, foreign_key: true, null: false, index: true
      t.references :name, references: :options, index: true
      t.references :type, references: :options, index: true

      t.text :comment

      t.timestamps null: false
    end

    add_foreign_key :special_terms, :options, column: :name_id
    add_foreign_key :special_terms, :options, column: :type_id
  end
end
