class SmartCsvImportWorker < BaseWorker
  def perform(s3_file_path, klass, id_object, company_id, original_filename)
    obj = S3_BUCKET.object(s3_file_path)
    return unless obj && obj.exists?
    tempfile_path = Tempfile.new(original_filename, Dir.tmpdir).path
    obj.download_file(tempfile_path, mode: 'auto')

    begin
      opts = {
          file: tempfile_path,
          import_subject: klass,
          user_id: id_object,
          company_id: company_id,
          original_filename: original_filename,
      }
      klass.constantize.new(opts).perform
      obj.delete
    rescue Exception => e
      obj.delete
      raise
    end
  end
end
