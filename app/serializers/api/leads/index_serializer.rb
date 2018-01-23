class Api::Leads::IndexSerializer < ActiveModel::Serializer
  attributes :id, :name, :title, :email, :country, :state, :budget, :notes, :created_at, :accepted_at, :company_name,
             :rejected_at, :reassigned_at, :reopened_at, :user, :contact, :clients, :untouched_days, :client, :deals, :company_name

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
    if object.company_name.present?
      company.clients.by_name(object.company_name).as_json(override: true, only: [:id, :name])
    end
  end

  def client
    object.client.serializable_hash(only: [:id, :name]) rescue nil
  end

  def deals
    object.deals.serializable_hash(only: [:id, :name, :budget]) rescue nil
  end

  private

  def company
    object.company
  end

  def date_for_untouched_calculation
    object.reopened_at.present? ? object.reopened_at : object.created_at
  end
end
