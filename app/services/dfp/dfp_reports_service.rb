module DFP
  class IntegrationErrors < StandardError
  end

  class DfpLogger
    def initialize(dfp_client)
      @dfp_client = dfp_client
    end
  end

  class DfpReportsService
    API_VERSION = :v201702
    MAX_RETRIES = 5
    RETRY_INTERVAL = 1

    # networkCode=122003474

    def initialize(credentials, network_code)
      @credentials = credentials
      @network_code = network_code
      authenticate_with_credentials
      apply_logger
    end

    def generate_report_by_saved_query(query_id)
      query = fetch_saved_query_by_id(query_id)
      job = run_report_job_by_query(query)
      check_report_status
      get_report_by_id(job[:id])
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
        first_result[:report_query]
      else
        raise DFP::IntegrationErrors, 'There is no report with such id'
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

    attr_reader :report_job

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

    def report_service
      @report_service ||= dfp_client.service(:ReportService, API_VERSION)
    end

    def apply_logger
      logger = Logger.new("#{Rails.root}/log/dfp.log")
      logger.level = Logger::DEBUG
      dfp_client.logger = logger
    end

    def dfp_client
      @dfp ||= DfpApi::Api.new(authentication: { method: 'OAUTH2_SERVICE_ACCOUNT', oauth2_hash: @credentials, application_name: 'boostr', network_code: @network_code}, service: { environment: 'PRODUCTION' })
    end
  end
end

