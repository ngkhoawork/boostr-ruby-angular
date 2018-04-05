class Csv::Lead
  include ActiveModel::Validations

  attr_accessor :company_id, :first_name, :last_name, :title, :email, :company_name, :country, :state, :budget, :notes,
                :status, :assigned_to, :skip_assignment, :created_from

  validates :first_name, :last_name, :email, :country, :state, :budget, :status, :skip_assignment, :created_from,
            presence: true
  validate :check_status
  validate :user_presence
  validate :check_created_from
  validate :check_skip_assignment

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
      user_id: determine_assignee,
      skip_callback: skip_assignment?,
      created_from: created_from
    }
  end

  def determine_assignee
    skip_assignment? ? assignee.id : nil
  end

  def skip_assignment?
    skip_assignment.downcase.eql?('true')
  end

  def check_skip_assignment
    if skip_assignment.blank? || !['true', 'false'].include?(skip_assignment.downcase)
      errors.add(:skip_assignment, "should be one from true or false" )
    end
  end

  def check_status
    if status.blank? || !::Lead::STATUSES.include?(status.downcase)
      errors.add(:status, "should be one from #{::Lead::STATUSES.join(', ')}" )
    end
  end

  def user_presence
    if assigned_to.present? && assignee.nil? && skip_assignment?
      errors.add(:user, 'is not present in system')
    end
  end

  def check_created_from
    if created_from.blank? || !::Lead::CREATED_FROM_LIST.include?(created_from.downcase)
      errors.add(:created_from, "should be one from #{::Lead::CREATED_FROM_LIST.join(', ')}" )
    end
  end
end
