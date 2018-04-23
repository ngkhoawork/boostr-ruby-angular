class SlackApiConfiguration < ApiConfiguration
  has_one :workflow_action, foreign_key: :api_configuration_id, dependent: :destroy

  attr_encrypted :password, key: Rails.application.secrets.secret_key_base

  def workflow_action_name
    'Post to Slack'
  end

  def workflow_action
    'slack_message'
  end

  def workflowable?
    true
  end
end
