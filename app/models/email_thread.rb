class EmailThread < ActiveRecord::Base
  has_many :email_open, foreign_key: :thread_id, primary_key: :email_thread_id

  validates :email_thread_id, presence: true, uniqueness: true

  def self.threads thread_ids
    select('email_thread_id,
            COUNT(email_opens.id) AS email_opens_count')
    .joins(:email_open)
    .where(email_thread_id: thread_ids)
    .group('email_threads.id')
  end

  def self.thread_list thread_ids
    threads(thread_ids).as_json.map{ |thread|
      thread.merge!({
        first_opened_email: EmailOpen.by_thread(thread['email_thread_id']).first
      }).except('id')
    }
  end
end
