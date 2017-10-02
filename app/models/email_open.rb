class EmailOpen < ActiveRecord::Base
  belongs_to :email_thread, foreign_key: :thread_id, primary_key: :email_thread_id

  scope :by_thread, -> (thread_id) { where(thread_id: thread_id).order('opened_at') }

  validates :thread_id, :email,  presence: true
end
