class EmailThread < ActiveRecord::Base
  has_many :email_open, foreign_key: :guid, primary_key: :email_guid

  validates :email_guid, presence: true, uniqueness: true

  def self.threads thread_ids
    select('email_guid,
            COUNT(email_opens.id) AS email_opens_count')
    .joins(:email_open)
    .where(email_guid: thread_ids)
    .group('email_threads.id')
  end

  def self.thread_list thread_ids
    threads(thread_ids).as_json.map{ |thread|
      thread.merge!({
        first_opened_email: EmailOpen.by_thread(thread['email_guid']).first
      }).except('id')
    }
  end
end
