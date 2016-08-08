class Reminder < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :user
  belongs_to :remindable, polymorphic: true

  validates :remindable_id, :remind_on, :name, presence: true
end
