class PublisherDailyActualsImportWorker < BaseWorker
  def perform(company_id, s3_file_path, original_filename)
    obj = S3_BUCKET.object(s3_file_path)
    if obj && obj.exists?
      tempfile_path = Tempfile.new(original_filename, Dir.tmpdir).path
      obj.download_file(tempfile_path, mode: 'auto')

      begin
        Importers::PublisherDailyActualsService.new(
          company_id: company_id,
          file: tempfile_path,
          original_filename: original_filename
        ).perform
      rescue Exception => e
        raise
      ensure
        obj.delete
      end
    end
  end
end
