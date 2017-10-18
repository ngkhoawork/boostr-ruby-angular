class UsersImportWorker < BaseWorker
  def perform(user_id, s3_file_path, original_filename, import_subject)
    inviter = User.find(user_id)

    obj = S3_BUCKET.object(s3_file_path)
    if obj && obj.exists?
      tempfile_path = Tempfile.new(original_filename, Dir.tmpdir).path
      obj.download_file(tempfile_path, mode: 'auto')

      begin
        Importers::UsersService.new(inviter: inviter, company_id: inviter.company_id, file: tempfile_path, import_subject: import_subject).perform
        obj.delete
      rescue Exception => e
        obj.delete
        raise
      end
    end

  end
end