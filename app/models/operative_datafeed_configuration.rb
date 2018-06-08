class OperativeDatafeedConfiguration < ApiConfiguration
  validates :api_email, :encrypted_password, presence: true
  attr_encrypted :password, key: Rails.application.secrets.secret_key_base

  has_one :datafeed_configuration_details, foreign_key: :api_configuration_id, dependent: :destroy
  accepts_nested_attributes_for :datafeed_configuration_details

  delegate :auto_close_deals, :revenue_calculation_pattern, :product_mapping,
           :exclude_child_line_items, :run_intraday?, :run_fullday?,
           :company_name, :job_id, :skip_not_changed?, to: :datafeed_configuration_details, prefix: false

  ALLOWED_RERUN_STATUSES = [
    :complete, :failed, :interrupted, nil
  ].freeze

  def self.metadata
    {
      revenue_calculation_patterns: DatafeedConfigurationDetails::REVENUE_CALCULATION_PATTERNS,
      product_mapping: DatafeedConfigurationDetails::PRODUCT_MAPPING
    }
  end

  before_save do
    set_company_name
  end

  def set_company_name
    datafeed_configuration_details.update(company_name: company.name) if company_name.blank?
  end

  def job_status
    Sidekiq::Status::status(job_id)
  end

  def can_be_scheduled?
    ALLOWED_RERUN_STATUSES.include?(job_status)
  end

  def start_job(job_type: 'intraday')
    if can_be_scheduled?
      datafeed_configuration_details.update(job_id: worker(job_type).set(queue: queue_selector).perform_async(id))
    end
  end

  def queue_selector
    if Rails.env == 'production'
      'daily:operative_datafeed_generator'
    else
      'default'
    end
  end

  def worker(job_type)
    if job_type == 'fullday'
      OperativeDatafeedFulldayCompanyWorker
    elsif job_type == 'intraday'
      OperativeDatafeedIntradayCompanyWorker
    end
  end
end
