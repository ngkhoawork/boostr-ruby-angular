class EmailThread < ActiveRecord::Base
  has_many :email_open, foreign_key: :guid, primary_key: :email_guid

  validates :email_guid, :thread_id, presence: true, uniqueness: true

  def self.threads thread_ids
    select('thread_id,
            email_guid AS thread_guid,
            COUNT(email_opens.id) AS email_opens_count')
    .joins(:email_open)
    .where(thread_id: thread_ids)
    .group('email_threads.id')
  end

  def self.thread_list thread_ids
    data = {}
    threads(thread_ids).as_json.map{ |thread|
      thread.merge!({
        first_opened_email: EmailOpen.by_thread(thread['thread_guid']).first
      })

      data.merge!("#{thread['thread_id']}" => {}.merge!(thread.except!('thread_id')))
    }

    data
  end
end
