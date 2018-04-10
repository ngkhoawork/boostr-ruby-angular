class CreateLeads < ActiveRecord::Migration
  def change
    create_table :leads do |t|
      t.string :first_name
      t.string :last_name
      t.string :title
      t.string :email
      t.string :company_name
      t.string :country
      t.string :state
      t.integer :budget
      t.string :notes
      t.string :status
      t.integer :company_id, index: true
      t.integer :user_id, index: true

      t.timestamps null: false
    end
  end
end
