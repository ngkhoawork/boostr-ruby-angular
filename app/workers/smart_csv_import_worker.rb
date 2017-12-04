class SmartCsvImportWorker < BaseWorker
  def perform(s3_file_path, klass, id_object, original_filename)
    obj = S3_BUCKET.object(s3_file_path)
    if obj && obj.exists?
      tempfile_path = Tempfile.new(original_filename, Dir.tmpdir).path
      obj.download_file(tempfile_path, mode: 'auto')

      csv_file = File.open(tempfile_path, "r:ISO-8859-1")

      begin
        klass.constantize.import(file: tempfile_path, import_subject: klass, user_id: id_object, original_filename: original_filename)
        obj.delete
      rescue Exception => e
        obj.delete
        raise
      end
    end
  end
end
