class EmailThread < ActiveRecord::Base
  has_many :email_opens, foreign_key: :guid, primary_key: :email_guid
  belongs_to :user

  validates :email_guid, :thread_id, presence: true, uniqueness: true

  scope :without_opens, -> () {  includes(:email_opens).where(email_opens: {id: nil}) }
  scope :search_by_email_threads, -> (term) { where("lower(subject) LIKE :term OR lower(recipient) LIKE :term OR lower(recipient_email) LIKE :term", term: "%#{term}%".downcase)}

  def self.threads thread_ids
    select('thread_id,
            email_guid AS thread_guid,
            COUNT(email_opens.id) AS email_opens_count')
    .joins('LEFT OUTER JOIN email_opens ON email_opens.guid = email_threads.email_guid')
    .where(thread_id: thread_ids)
    .group('email_threads.id')
  end

  def self.thread_list thread_ids
    threads(thread_ids).as_json.each_with_object({}) { |thread, result|
      result[thread['thread_id']] = thread.merge!({
        last_open: EmailOpen.by_thread(thread['thread_guid']).last
      })
    }
  end

  def last_five_opens
    email_opens.order("created_at DESC").first(5)
  end
end
