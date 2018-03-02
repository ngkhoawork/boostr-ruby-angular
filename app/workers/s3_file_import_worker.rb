class S3FileImportWorker < BaseWorker
  def perform(klass, company_id, s3_file_path, original_filename)
    obj = S3_BUCKET.object(s3_file_path)

    if obj && obj.exists?
      tempfile_path = Tempfile.new(original_filename, Dir.tmpdir).path
      obj.download_file(tempfile_path, mode: 'auto')

      begin
        klass.constantize.new(company_id: company_id, file: tempfile_path).perform
        obj.delete
      rescue Exception => e
        obj.delete
        raise
      end
    end
  end
end