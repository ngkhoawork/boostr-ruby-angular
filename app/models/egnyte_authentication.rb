class EgnyteAuthentication < ActiveRecord::Base
  belongs_to :user, required: true

  def passed?
    !!access_token
  end
end
