class PublisherDailyActual < ActiveRecord::Base
  belongs_to :publisher, required: true
  belongs_to :currency

  validates :date, :available_impressions, :filled_impressions, presence: true

  after_validation :calculate_fill_rate

  private

  def calculate_fill_rate
    return unless available_impressions && filled_impressions

    self.fill_rate = (filled_impressions.to_f/available_impressions.to_f) * 100
  end
end
