class Api::Leads::IndexSerializer < ActiveModel::Serializer
  attributes :id, :name, :title, :email, :country, :state, :budget, :notes, :created_at, :accepted_at, :company_name,
             :rejected_at, :reassigned_at, :user, :contact, :clients, :untouched_days, :rejected_reason

  has_many :deals, serializer: Api::Leads::DealSerializer
  has_one :client, serializer: Api::Leads::ClientSerializer

  def contact
    object.contact.serializable_hash(only: [:id, :name]) rescue nil
  end

  def user
    object.user.serializable_hash(only: [:id], methods: [:name]) rescue nil
  end

  def untouched_days
    (Date.current - date_for_untouched_calculation.to_date).to_i.to_s if object.status.downcase.eql?(Lead::NEW)
  end

  def clients
    if object.company_name.present? && object.client.blank?
      ActiveModel::ArraySerializer.new(
        suggested_clients,
        each_serializer: Api::Leads::ClientSerializer
      )
    end
  end

  private

  def company
    object.company
  end

  def date_for_untouched_calculation
    object.reassigned_at.present? ? object.reassigned_at : object.created_at
  end

  def suggested_clients
    company.clients.fuzzy_name_string_search(object.company_name)
  end
end
