class AddSlackAttachmentMappingsToWorkflowActions < ActiveRecord::Migration
  def change
    add_column :workflow_actions, :slack_attachment_mappings, :text
  end
end
