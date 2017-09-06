class AddPositionAndStatusToActivityTypes < ActiveRecord::Migration
  def change
    add_column :activity_types, :position, :integer
    add_column :activity_types, :status, :boolean, default: true

    assign_positions
  end

  def assign_positions
    ids = Company.all.ids
    ids.each do |company_id|
      types = ActivityType.where(company_id: company_id).reorder(:name)
      ActivityType.transaction do
        types.each.with_index(1) { |type, index| type.update(position: index) }
      end
    end
  end
end
