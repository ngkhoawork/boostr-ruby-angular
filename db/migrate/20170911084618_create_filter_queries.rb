class CreateFilterQueries < ActiveRecord::Migration
  def change
    create_table :filter_queries do |t|
      t.string :name
      t.integer :company_id
      t.integer :user_id
      t.string :query_type
      t.boolean :global, default: false
      t.jsonb :filter_params, null: false, default: '{}'

      t.timestamps null: false
    end
  end
end
