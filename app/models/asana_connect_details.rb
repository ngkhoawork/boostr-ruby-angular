class AsanaConnectDetails < ActiveRecord::Base
  belongs_to :api_configuration

  validates_presence_of :project_name, :workspace_name, allow_nil: false
end
