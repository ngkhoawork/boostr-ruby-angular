class EgnyteIntegration < ActiveRecord::Base
  REQUESTED_ACCESS_TOKEN_MARKER = 'SHOULD_BE_REPLACED_WITH_ACCESS_TOKEN'.freeze

  belongs_to :company, required: true

  validates :company_id, uniqueness: true
  validate :connected_is_required_for_enabled

  def self.generate_state_token(salt)
    random_hash = Digest::MD5.hexdigest("#{DateTime.current}-#{salt}")

    "#{REQUESTED_ACCESS_TOKEN_MARKER}_#{random_hash}"
  end

  def self.find_by_state_token(state_token)
    find_by(access_token: state_token)
  end

  private

  def connected_is_required_for_enabled
    errors.add(:active, 'must be connected') if enabled? && !connected?
  end
end
