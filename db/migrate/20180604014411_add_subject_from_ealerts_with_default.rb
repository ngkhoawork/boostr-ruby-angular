class AddSubjectFromEalertsWithDefault < ActiveRecord::Migration
  def change
    add_column :ealerts, :subject, :string, default: 'eAlert - {{deal.name}}'
  end
end
