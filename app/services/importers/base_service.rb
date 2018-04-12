class Importers::BaseService < BaseService

  def initialize(options = {})
    super(options)
    @report_csv = open_file
  end

  private

  attr_reader :report_csv

  def import
    parsed_csv.each do |row|
      import_row(row)
    end
    csv_import_log.set_file_source(file_name)
    csv_import_log.save
  end

  def parsed_csv
    SmarterCSV.process(report_csv, parser_options)
  end

  def import_row(row)
    csv_object = build_csv(row)
    csv_import_log.count_processed

    if csv_object.valid?
      begin
        if csv_object.perform
          csv_import_log.count_imported
          after_import_row(csv_object) if method_defined?(:after_import_row)
        else
          csv_import_log.count_failed
          csv_import_log.log_error csv_object.object_errors
        end
      rescue Exception => e
        csv_import_log.count_failed
        csv_import_log.log_error ['Internal Server Error', row.compact.to_s, e.message]
      end
    else
      csv_import_log.count_failed
      csv_import_log.log_error csv_object.errors.full_messages
    end
  end

  def csv_import_log
    @csv_import_log ||= CsvImportLog.new(company_id: company_id, object_name: import_subject, source: import_source)
  end

  def parser_options
    raise NotImplementedError, 'parser_options method should be implemented in your class'
  end

  def build_csv(row)
    raise NotImplementedError, 'build_csv(row) method should be implemented in your class'
  end

  def import_source
    raise NotImplementedError, 'import_source method should be implemented in your class. Return nil if non ui source'
  end

  def open_file
    begin
      File.open(file, 'r:bom|utf-8')
    rescue Exception => e
      csv_import_log = CsvImportLog.new(company_id: company_id, object_name: import_subject, source: import_source)
      csv_import_log.set_file_source(file_name)
      csv_import_log.log_error [e.class.to_s, e.message]
      csv_import_log.save
    end
  end

  def file_name
    @original_filename || file
  end

  def method_defined?(method_name)
    self.class.method_defined?(method_name) || self.class.private_method_defined?(method_name)
  end
end
