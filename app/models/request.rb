class Request < ActiveRecord::Base
  belongs_to :deal
  belongs_to :company

  belongs_to :requester, class_name: 'User'
  belongs_to :assignee, class_name: 'User'
  belongs_to :requestable, polymorphic: true

  validates_length_of :description, maximum: 1000
  validates_length_of :resolution, maximum: 1000

  default_scope { order(created_at: :desc) }

  scope :by_request_type, -> (type) { where(request_type: type) if type.present? }
  scope :by_status, -> (status) { where(status: status) if status.present? }

  after_create :notify_users

  private

  def notify_users
    if self.status == 'New'
      RequestsMailer.send_email(request_mail_recipients, self.id).deliver_later(queue: "default")
    end
  end

  def request_mail_recipients
    self.company.users.where("#{self.request_type.downcase}_requests_access": true).map(&:email)
  end
end
