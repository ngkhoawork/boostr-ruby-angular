class Request < ActiveRecord::Base
  belongs_to :deal
  belongs_to :company

  belongs_to :requester, class_name: 'User'
  belongs_to :assignee, class_name: 'User'
  belongs_to :requestable, polymorphic: true

  validates_length_of :description, maximum: 1000
  validates_length_of :resolution, maximum: 1000
  validates_presence_of :resolution, on: :update, if: :request_is_denied

  default_scope { order(created_at: :desc) }

  scope :by_request_type, -> (type) { where(request_type: type) if type.present? }
  scope :by_status, -> (status) { where(status: status) if status.present? }

  after_create :notify_assignee
  after_update do
    notify_assignee if self.status_changed?
    notify_requester if self.status_changed?
  end

  def request_is_completed
    self.status == 'Completed'
  end

  def request_is_denied
    self.status == 'Denied'
  end

  private

  def notify_assignee
    if self.status == 'New'
      RequestsMailer.new_request(request_mail_recipients, self.id).deliver_later(queue: "default")
    end
  end

  def request_mail_recipients
    self.company.users.where("#{self.request_type.downcase}_requests_access": true).map(&:email)
  end

  def notify_requester
    if self.status == 'Completed' || self.status == 'Denied'
      RequestsMailer.update_request(requester_email, self.id).deliver_later(queue: "default")
    end
  end

  def requester_email
    [self.requester.try(:email)]
  end
end
