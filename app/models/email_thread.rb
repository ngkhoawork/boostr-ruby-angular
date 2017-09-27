class EmailThread < ActiveRecord::Base
  has_many :email_open, foreign_key: :thread_id, primary_key: :email_thread_id

  validates_presence_of :email_thread_id
  validates_uniqueness_of :email_thread_id
end
