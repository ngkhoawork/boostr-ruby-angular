class PublisherDailyActual < ActiveRecord::Base
  belongs_to :publisher, required: true

  validates :date, :available_impressions, :filled_impressions, presence: true

  after_validation :calculate_fill_rate

  private

  def calculate_fill_rate
    return unless available_impressions && filled_impressions

    self.fill_rate = (filled_impressions/available_impressions) * 100
  end
end
