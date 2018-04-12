class Workflows::WorkflowListSerializer < ActiveModel::Serializer
  attributes(
      :id,
      :name,
      :created_by,
      :switched_on,
      :workflowable_type,
      :description,
      :fire_on_create,
      :fire_on_update,
      :fire_on_destroy
  )

  has_one :workflow_action
  has_many :workflow_criterions

  private

  def created_by
    object.user.name
  end
end
