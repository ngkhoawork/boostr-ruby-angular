class Csv::Lead
  include ActiveModel::Validations

  attr_accessor :company_id, :first_name, :last_name, :title, :email, :company_name, :country, :state, :budget, :notes,
                :status, :assigned_to, :skip_assignment

  validates :first_name, :last_name, :email, :country, :state, :budget, :status, :skip_assignment, presence: true
  validate :check_status
  validate :user_presence

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def assignee
    @_assignee ||= Company.find(company_id).users.find_by(email: assigned_to)
  end

  def perform
    Lead.create lead_attributes
  end

  def persisted?
    false
  end

  def lead_attributes
    {
      company_id: company_id,
      first_name: first_name,
      last_name: last_name,
      title: title,
      email: email,
      company_name: company_name,
      country: country,
      state: state,
      budget: budget,
      notes: notes,
      status: status,
      user_id: assignee.id,
      skip_callback: convert_skip_assignment_to_bool
    }
  end

  def convert_skip_assignment_to_bool
    skip_assignment.downcase.eql?('true')
  end

  def check_status
    unless ::Lead::STATUSES.include? status.downcase
      errors.add(:status, "should be one from #{::Lead::STATUSES.join(', ')}" )
    end
  end

  def user_presence
    if assigned_to.present? && assignee.nil?
      errors.add(:user, 'is not present in system')
    end
  end
end
