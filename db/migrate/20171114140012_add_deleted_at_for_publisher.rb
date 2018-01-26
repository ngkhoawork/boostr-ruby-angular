class AddDeletedAtForPublisher < ActiveRecord::Migration
  def change
    add_column :publishers, :deleted_at, :datetime
  end
end
