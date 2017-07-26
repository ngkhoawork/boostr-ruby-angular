class FixTypoActivityTypes < ActiveRecord::Migration
  def change
    types = ActivityType.where(action: 'had insternal meeting with')
    types.update_all(action: 'had internal meeting with')
  end
end
