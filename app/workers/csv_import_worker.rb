class CsvImportWorker < BaseWorker
  def perform(file_path, klass, id_object, original_filename)
    csv_file = File.open(file_path, "r:ISO-8859-1")
    klass.constantize.import(csv_file, id_object, original_filename)
  end
end
