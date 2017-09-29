class EmailOpen < ActiveRecord::Base
  belongs_to :email_thread, foreign_key: :thread_id, primary_key: :email_thread_id

  validates :thread_id, :email,  presence: true
end
