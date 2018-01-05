class RenameSim1ToSum1OfPublisherCustomFields < ActiveRecord::Migration
  def up
    rename_column :publisher_custom_fields, :sim1, :sum1
  end

  def down
    rename_column :publisher_custom_fields, :sum1, :sim1
  end
end
