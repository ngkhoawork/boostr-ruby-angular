class Users::BaseSerializer < ActiveModel::Serializer
  attributes  :id,
              :company_id,
              :email,
              :name,
              :first_name,
              :last_name,
              :team_id,
              :is_leader,
              :office

  def is_leader
    object.leader?
  end
end
