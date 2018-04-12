class CsvImportWorker < BaseWorker
  def perform(s3_file_path, klass, id_object, original_filename)
    obj = S3_BUCKET.object(s3_file_path)
    if obj && obj.exists?
      tempfile_path = Tempfile.new(original_filename, Dir.tmpdir).path
      obj.download_file(tempfile_path, mode: 'auto')

      csv_file = File.open(tempfile_path, "r:UTF-8")

      begin
        klass.constantize.import(csv_file, id_object, original_filename)
        obj.delete
      rescue Exception => e
        obj.delete
        raise
      end
    end
  end
end
