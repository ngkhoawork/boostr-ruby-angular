class LeadsImportWorker < BaseWorker
  def perform(user_id, s3_file_path, original_filename)
    company_id = User.find(user_id).company_id
    obj = S3_BUCKET.object(s3_file_path)

    if obj && obj.exists?
      tempfile_path = Tempfile.new(original_filename, Dir.tmpdir).path
      obj.download_file(tempfile_path, mode: 'auto')

      begin
        Importers::LeadsService.new(company_id: company_id, file: tempfile_path).perform

        obj.delete
      rescue Exception => e
        obj.delete
        raise
      end
    end
  end
end
