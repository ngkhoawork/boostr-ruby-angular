class Lead < ActiveRecord::Base
  ACCEPTED = 'accepted'.freeze
  REJECTED = 'rejected'.freeze
  REMINDER = 'reminder'.freeze
  REASSIGNMENT = 'reassignment'.freeze

  has_many :deals
  has_many :notification_reminders

  has_one :contact
  has_one :client

  belongs_to :company
  belongs_to :user

  scope :new_records, -> { where(status: nil) }
  scope :accepted, -> { where(status: ACCEPTED) }
  scope :rejected, -> { where(status: REJECTED) }
  scope :by_company_id, -> (company_id) { where(company_id: company_id) }
  scope :reassigned, -> { where.not(reassigned_at: nil) }
  scope :notification_reminders_by_dates, -> (reminder_type, start_date, end_date) do
    joins(:notification_reminders)
      .where('notification_reminders.notification_type = ? AND
              notification_reminders.sending_time BETWEEN ? AND ?', reminder_type, start_date, end_date)
  end

  after_create :match_contact, :assign_reviewer, :add_notifications_reminder, :add_notifications_reassignment,
               on: :create
  after_save :add_notifications_reminder, :add_notifications_reassignment, if: :reassigned_at_changed?
  after_save :remove_notifications_reminders, if: :accepted_or_rejected?

  def name
    "#{first_name} #{last_name}" rescue first_name || last_name
  end

  private

  def match_contact
    self.contact = matched_contact if matched_contact.present?
  end

  def matched_contact
    @_matched_contact ||=
      company.contacts.joins(:address).find_by(addresses: { email: email }) if company.present?
  end

  def assign_reviewer
    update_columns(user_id: company.users.sample(1).first.id) if self.user_id.nil?
  end

  def add_notifications_reminder
    remove_notifications_reminders
    self.notification_reminders.create(notification_type: REMINDER, sending_time: 1.day.from_now)
  end

  def add_notifications_reassignment
    self.notification_reminders.create(notification_type: REASSIGNMENT, sending_time: 2.days.from_now)
  end

  def remove_notifications_reminders
    self.notification_reminders.destroy_all
  end

  def accepted_or_rejected?
    (accepted_at_changed? && !accepted_at.nil?) || (rejected_at_changed? && !rejected_at.nil?)
  end

  def reassigned_at_present?
    reassigned_at_changed?
  end
end
