module DFP
  class IntegrationErrors < StandardError
  end

  FIXED_DATE_RANGE_TYPES = %w(TODAY
                              YESTERDAY
                              LAST_WEEK
                              LAST_MONTH
                              REACH_LIFETIME
                              NEXT_DAY
                              NEXT_90_DAYS
                              NEXT_WEEK
                              NEXT_MONTH
                              CURRENT_AND_NEXT_MONTH
                              NEXT_QUARTER
                              NEXT_3_MONTHS
                              NEXT_12_MONTHS)

  class ReportsService < BaseService
    API_VERSION = :v201802
    MAX_RETRIES = 5
    RETRY_INTERVAL = 2

    def initialize(options = {})
      super(options)
      authenticate_with_credentials
      apply_stdout_logger
      set_logger_interceptor
    end

    def generate_report_by_saved_query(query_id, options = {})
      begin
        fetch_saved_query_by_id(query_id)
        modify_date_range_to_custom_date_range(options[:start_date], options[:end_date]) if options.any?
        run_report_job_by_query(saved_query)
        check_report_status
        get_report_by_id(report_job[:id])
      rescue DfpApi::V201702::ReportService::ApiException => e
        puts e.class
      end
    end

    def get_report_by_id(report_job_id)
      report_service.get_report_download_url_with_options(report_job_id, report_download_options)
    end

    def fetch_saved_query_by_id(saved_query_id)
      statement = DfpApi::FilterStatement.new(
          'WHERE id = :id',
          [
              {:key => 'id',
               :value => {
                   :value => saved_query_id,
                   :xsi_type => 'NumberValue'}
              }
          ],
          1
      )

      response = report_service.get_saved_queries_by_statement(statement.toStatement)
      if !response[:results].nil?
        first_result = response[:results].first
        @saved_query = first_result[:report_query]
      else
        raise DFP::IntegrationErrors, 'There is no report with such id'
      end
    end

    def modify_date_range_to_custom_date_range(start_date, end_date)
      if FIXED_DATE_RANGE_TYPES.include?(saved_query[:date_range_type])
        saved_query[:date_range_type] = 'CUSTOM_DATE'
        saved_query[:start_date] = { year: start_date.year,
                                     month: start_date.month,
                                     day: start_date.day }
        saved_query[:end_date] = { year: end_date.year,
                                   month: end_date.month,
                                   day: end_date.day }
      end
    end

    def check_report_status
      MAX_RETRIES.times do
        report_job_status = report_service.get_report_job_status(report_job[:id])
        break unless report_job_status == 'IN_PROGRESS'
        sleep(RETRY_INTERVAL)
      end
    end

    def run_report_job_by_query(query)
      validate_report_query_params(query)
      @report_job = report_service.run_report_job(report_query: query)
    end

    private

    attr_accessor :report_job, :saved_query

    def report_download_options
      { :export_format => 'CSV_DUMP', :use_gzip_compression => false }
    end

    def authenticate_with_credentials
      dfp_client.authorize
    end

    def validate_report_query_params(params)
      unless params.kind_of?(Hash)
        raise DFP::IntegrationErrors, 'You should provide Hash instead of ' + params.class.to_s
      end
    end

    def set_logger_interceptor
      GoogleAdsSavon.config.hooks.reject(:logger_hook)
      GoogleAdsSavon.config.hooks.define(:logger_hook, :soap_request) do |callback, req|
        response = callback.call
        DFP::LoggerService.new(request: req, response: response, company_id: company_id, dfp_query_type: dfp_query_type).create_log!
        response
      end
    end

    def report_service
      @report_service ||= dfp_client.service(:ReportService, API_VERSION)
    end

    def apply_stdout_logger
      logger = Logger.new("#{Rails.root}/log/dfp.log")
      logger.level = Logger::DEBUG
      dfp_client.logger = logger
    end

    def dfp_client
      @dfp ||= DfpApi::Api.new(authentication: { method: 'OAUTH2_SERVICE_ACCOUNT', oauth2_json_string: credentials, application_name: 'boostr', network_code: network_code}, service: { environment: 'PRODUCTION' })
    end
  end
end

