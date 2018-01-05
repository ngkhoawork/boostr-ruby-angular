class AddDefaultValueToSalesStages < ActiveRecord::Migration
  def up
    change_column_default :sales_stages, :open, true
    change_column_default :sales_stages, :active, true
  end

  def down
    change_column_default :sales_stages, :open, nil
    change_column_default :sales_stages, :active, nil
  end
end
