class UpdateQuotas < ActiveRecord::Migration
  def change
    add_reference :quota, :product, polymorphic: true, index: true
    add_column :quota, :value_type, :integer
    add_index :quota, [:time_period_id, :user_id, :value_type, :product_id, :product_type], unique: true, name: 'index_composite_quota'
    Quota.update_all(value_type: 'gross')
  end
end
