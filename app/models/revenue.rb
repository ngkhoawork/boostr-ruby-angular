class Revenue < ActiveRecord::Base
  belongs_to :company
  belongs_to :client
  belongs_to :user

  def client_name
    client.name if client.present?
  end

  def user_name
    user.name
  end

  def as_json(options = {})
    super(options.merge(methods: [:client_name, :user_name]))
  end
end
