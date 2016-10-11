class AddCommentAndSubtypeToAssets < ActiveRecord::Migration
  def change
    add_column :assets, :comment, :string
    add_column :assets, :subtype, :string
  end
end
