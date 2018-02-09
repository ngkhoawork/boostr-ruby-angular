class Lead < ActiveRecord::Base
  NEW = 'new'.freeze
  ACCEPTED = 'accepted'.freeze
  REJECTED = 'rejected'.freeze
  STATUSES = [NEW, ACCEPTED, REJECTED]
  REMINDER = 'reminder'.freeze
  REASSIGNMENT = 'reassignment'.freeze

  attr_accessor :skip_callback

  has_many :deals
  has_many :notification_reminders

  belongs_to :company
  belongs_to :user
  belongs_to :contact
  belongs_to :client

  scope :new_records, -> { where('lower(status) = ?', NEW) }
  scope :accepted, -> { where('lower(status) = ?', ACCEPTED) }
  scope :rejected, -> { where('lower(status) = ?', REJECTED) }
  scope :by_company_id, -> (company_id) { where(company_id: company_id) }
  scope :notification_reminders_by_dates, -> (reminder_type, start_date, end_date) do
    joins(:notification_reminders)
      .where('notification_reminders.notification_type = ? AND
              notification_reminders.sending_time BETWEEN ? AND ?', reminder_type, start_date, end_date)
  end

  after_create :match_contact, :assign_reviewer, on: :create
  after_create :create_notification_reminders, on: :create, unless: :skip_callback
  after_create :send_new_assignment_email, unless: :skip_callback
  after_save :create_notification_reminders, if: :reassigned_at_changed?
  after_save :remove_notifications_reminders, if: :accepted_or_rejected?

  def name
    "#{first_name} #{last_name}" rescue first_name || last_name
  end

  def create_notification_reminders
    add_notifications_reminder
    add_notifications_reassignment
  end

  def assign_reviewer
    update_columns(user_id: company.users.sample(1).first.id) if self.user_id.nil?
  end

  private

  def match_contact
    self.update(contact_id: matched_contact.id) if matched_contact.present?
  end

  def matched_contact
    @_matched_contact ||=
      company.contacts.joins(:address).find_by(addresses: { email: email }) if company.present?
  end

  def add_notifications_reminder
    remove_notifications_reminders

    self.notification_reminders.create(
      notification_type: REMINDER,
      sending_time: Leads::ReminderTimeCalculationService.new.determine_notifications_reminder_time
    )
  end

  def add_notifications_reassignment
    self.notification_reminders.create(
      notification_type: REASSIGNMENT,
      sending_time: Leads::ReminderTimeCalculationService.new.determine_notifications_reassignment_time
    )
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

  def send_new_assignment_email
    LeadsMailer.new_leads_assignment(self).deliver_now
  end
end
