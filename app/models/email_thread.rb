class EmailThread < ActiveRecord::Base
  has_many :email_opens, foreign_key: :guid, primary_key: :email_guid
  belongs_to :user

  validates :email_guid, :thread_id, presence: true, uniqueness: true

  scope :without_opens, -> () {  includes(:email_opens).where(email_opens: {id: nil}) }
  scope :search_by_email_threads, -> (term) { where("lower(subject) LIKE :term OR lower(recipient) LIKE :term OR lower(recipient_email) LIKE :term", term: "%#{term}%".downcase)}

  def self.threads current_user_id, thread_ids
    find_by_sql(["SELECT * FROM (
      SELECT
        thread_id,
        email_guid AS thread_guid,
        email_opens.location,
        email_opens.opened_at,
        email_opens.ip,
        email_opens.device,
        email_opens.is_gmail,
        COUNT(email_opens.ID) OVER (partition by email_threads.ID) AS email_opens_count,
        row_number() OVER (partition by email_threads.ID ORDER BY email_opens.opened_at DESC) rn
      FROM
        email_threads
      LEFT OUTER JOIN email_opens ON email_opens.guid = email_threads.email_guid
      WHERE
       email_threads.user_id = ?
       AND email_threads.thread_id IN (?)
      ) q
      WHERE q.rn = 1", current_user_id, thread_ids])

  end

  def self.thread_list current_user_id, thread_ids
    threads(current_user_id, thread_ids).as_json.each_with_object({}) { |thread, result|
      result[thread['thread_id']] = thread.merge! last_opened_email thread
      result[thread['thread_id']].except! 'location', 'rn', 'ip', 'device', 'opened_at', 'is_gmail'
    }
  end

  def last_five_opens
    email_opens.order("created_at DESC").first(5)
  end

  private

  def self.last_opened_email thread
    if thread['opened_at']
      { last_open: { location: thread['location'],
                     ip: thread['ip'],
                     device: thread['device'],
                     opened_at: thread['opened_at'],
                     is_gmail: thread['is_gmail'] } }
    else
      { last_open: nil }
    end
  end
end
