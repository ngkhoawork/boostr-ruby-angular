class EmailThread < ActiveRecord::Base
  has_many :email_open, foreign_key: :thread_id, primary_key: :email_thread_id

  validates :email_thread_id, presence: true, uniqueness: true
end
