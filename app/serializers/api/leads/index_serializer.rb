class Api::Leads::IndexSerializer < ActiveModel::Serializer
  attributes :id, :name, :title, :email, :country, :state, :budget, :notes, :created_at, :accepted_at,
             :rejected_at, :reassigned_at, :user, :contact, :clients

  def contact
    object.contact.serializable_hash(only: [:id, :name]) rescue nil
  end

  def user
    object.user.serializable_hash(only: [:id], methods: [:name]) rescue nil
  end

  def untouched_days
    (object.updated_at.to_date - object.created_at.to_date).to_i
  end

  def clients
    if object.company_name.present?
      company.clients.by_name(object.company_name).as_json(override: true, only: [:id, :name])
    end
  end

  private

  def company
    object.company
  end
end
