class ChangeSlackAttachmentMappingField < ActiveRecord::Migration
  def up
    execute "ALTER TABLE workflow_actions ALTER COLUMN slack_attachment_mappings SET DEFAULT '[]'::JSON"
  end

  def down
    execute "ALTER TABLE workflow_actions ALTER COLUMN slack_attachment_mappings SET DEFAULT NULL"
  end
end