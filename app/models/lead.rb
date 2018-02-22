class Lead < ActiveRecord::Base
  NEW = 'new'.freeze
  ACCEPTED = 'accepted'.freeze
  REJECTED = 'rejected'.freeze
  STATUSES = [NEW, ACCEPTED, REJECTED]
  REMINDER = 'reminder'.freeze
  REASSIGNMENT = 'reassignment'.freeze
  NON_USA_STATE = 'non usa'.freeze
  WEB_FORM = 'web form'.freeze
  MARKETING = 'marketing'.freeze
  TRADESHOW = 'tradeshow'.freeze
  OTHER = 'other'.freeze
  CREATED_FROM_LIST = [WEB_FORM, MARKETING, TRADESHOW, OTHER]

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
    if self.user_id.nil?
      update_columns(user_id: next_available_user)

      update_rules_next_fields_value
    end
  end

  def update_rules_next_fields_value
    if find_rule.assignment_rules_users.count > 1
      find_next_available_rule.update(next: false)

      next_assignment_rules_user.present? ? next_assignment_rules_user.update(next: true) : first_assignment_rules_user.update(next: true)
    end
  end

  def next_available_user
    find_next_available_rule.user_id
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

  def find_rule
    @_rule ||= rule.blank? ? default_rule : rule
  end

  def rule
    state.downcase.eql?(NON_USA_STATE) ? rule_by_countries : rule_by_states_and_countries
  end

  def rule_by_countries
    order_rules_by_position.by_countries(country).first
  end

  def rule_by_states_and_countries
    order_rules_by_position.by_states(state).by_countries(country).first
  end

  def order_rules_by_position
    @_order_rules_by_position ||= AssignmentRule.by_company_id(company_id).order_by_position
  end

  def find_next_available_rule
    @_next_available_rule ||= find_rule.next_available_rule
  end

  def next_assignment_rules_user
    @_next_assignment_rules_user ||=
      find_rule.assignment_rules_users.find_by(position: find_next_available_rule.position.next)
  end

  def first_assignment_rules_user
    find_rule.assignment_rules_users.find_by(position: 0)
  end

  def default_rule
    order_rules_by_position.default
  end
end
