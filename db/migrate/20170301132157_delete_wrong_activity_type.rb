class DeleteWrongActivityType < ActiveRecord::Migration
  def change
    ActivityType.where(action: 'emailed with').destroy_all
  end
end
