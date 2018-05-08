class Teams::HierarchySerializer < Teams::BaseSerializer
  attributes :members_count
  has_many :children, serializer: Teams::HierarchySerializer
  has_many :members, serializer: Users::BaseSerializer
  has_many :all_leaders, serializer: Users::BaseSerializer, key: :leaders

  # def leaders
  #   object.all_leaders
  # end
end
