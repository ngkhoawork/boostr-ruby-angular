class RemoveSubjectFromEalerts < ActiveRecord::Migration
  def change
    remove_column :ealerts, :subject
  end
end
