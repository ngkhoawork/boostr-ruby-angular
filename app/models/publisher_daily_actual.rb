class PublisherDailyActual < ActiveRecord::Base
  belongs_to :publisher, required: true
  belongs_to :currency

  validates :date, :available_impressions, :filled_impressions, presence: true
  validate :filled_is_not_more_than_available_impressions

  after_validation :calculate_fill_rate

  delegate :curr_symbol, to: :currency, allow_nil: true

  private

  def calculate_fill_rate
    return unless available_impressions && filled_impressions

    self.fill_rate = (filled_impressions.to_f/available_impressions.to_f) * 100
  end

  def filled_is_not_more_than_available_impressions
    return if filled_impressions <= available_impressions

    errors.add(:filled_impressions, 'can not be more than available_impressions')
  end
end
