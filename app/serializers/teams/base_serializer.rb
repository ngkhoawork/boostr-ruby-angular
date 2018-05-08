class Teams::BaseSerializer < ActiveModel::Serializer
  attributes :id, :name, :leader_id, :parent_id, :sales_process_id, :members_count, :leader_name
end
