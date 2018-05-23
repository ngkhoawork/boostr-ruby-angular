class AddSubjectToEalerts < ActiveRecord::Migration
  def change
    add_column :ealerts, :subject, :string
  end
end
