class Reminder < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :user
  belongs_to :remindable, polymorphic: true

  validates :remindable_id, :remindable_type, :remind_on, :name, presence: true
  validates :completed, inclusion: { in: [ true, false ] }

  scope :by_id, -> (id, user_id) do
    where(id: id, user_id: user_id)
  end

  scope :user_reminders, -> (user_id) do
    where(user_id: user_id)
  end

  scope :by_remindable, -> (user_id, remindable_id, type) do
    where(user_id: user_id, remindable_id: remindable_id, remindable_type: type)
  end
end
