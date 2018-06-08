class Clients::ClientMemberSerializer < ActiveModel::Serializer
  attributes :id, 
             :share, 
             :first_name, 
             :last_name, 
             :name
  
  def name
    object.first_name + ' ' + object.last_name
  end
end
