class AddCommentToRevenues < ActiveRecord::Migration
  def change
    add_column :revenues, :comment, :text
  end
end
