class CsvImportLog < ActiveRecord::Base
  belongs_to :company
  serialize :error_messages, JSON

  def count_processed
    self.rows_processed += 1
  end

  def count_imported
    self.rows_imported += 1
  end

  def count_failed
    self.rows_failed += 1
  end

  def count_skipped
    self.rows_skipped += 1
  end

  def log_error(error)
    self.error_messages ||= []
    self.error_messages << { row: rows_processed, message: error }
  end

  def set_file_source(path)
    self.file_source = File.basename(path)
  end
end
