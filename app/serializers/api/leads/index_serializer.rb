class Api::Leads::IndexSerializer < ActiveModel::Serializer
  attributes :id, :name, :title, :email, :country, :state, :budget, :notes, :created_at, :accepted_at, :company_name,
             :rejected_at, :reassigned_at, :user, :contact, :clients, :untouched_days

  has_many :deals, serializer: Api::Leads::DealSerializer
  has_one :client, serializer: Api::Leads::ClientSerializer

  def contact
    object.contact.serializable_hash(only: [:id, :name]) rescue nil
  end

  def user
    object.user.serializable_hash(only: [:id], methods: [:name]) rescue nil
  end

  def untouched_days
    (Date.current - date_for_untouched_calculation.to_date).to_i if object.status.nil?
  end

  def clients
    if object.company_name.present? && object.client.blank?
      company.clients.by_name(object.company_name).as_json(override: true, only: [:id, :name])
    end
  end

  private

  def company
    object.company
  end

  def date_for_untouched_calculation
    object.reassigned_at.present? ? object.reassigned_at : object.created_at
  end
end
