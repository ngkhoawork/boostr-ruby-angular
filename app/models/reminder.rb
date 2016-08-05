class Reminder < ActiveRecord::Base
  belongs_to :user
  belongs_to :remindable, polymorphic: true

  validates :remindable_id, :remind_on, :name, presence: true
end
