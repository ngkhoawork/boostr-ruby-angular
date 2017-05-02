class Add4DecimalFieldsToAccountCf < ActiveRecord::Migration
  def change
    add_column :account_cfs, :number_4_dec1, :decimal, precision: 15, scale: 4
    add_column :account_cfs, :number_4_dec2, :decimal, precision: 15, scale: 4
    add_column :account_cfs, :number_4_dec3, :decimal, precision: 15, scale: 4
    add_column :account_cfs, :number_4_dec4, :decimal, precision: 15, scale: 4
    add_column :account_cfs, :number_4_dec5, :decimal, precision: 15, scale: 4
    add_column :account_cfs, :number_4_dec6, :decimal, precision: 15, scale: 4
    add_column :account_cfs, :number_4_dec7, :decimal, precision: 15, scale: 4
  end
end
