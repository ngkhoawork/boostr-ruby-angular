module UsesTempFiles
  def self.included(example_group)
    example_group.extend(self)
  end

  def in_directory_with_files(files)
    before do
      @pwd = Dir.pwd
      @tmp_dir = File.join(File.dirname(__FILE__), 'tmp')
      FileUtils.mkdir_p(@tmp_dir)
      Dir.chdir(@tmp_dir)

      FileUtils.mkdir_p(File.dirname(files[0]))
      files.map { |file| FileUtils.touch(file) }
    end

    define_method(:content_for_files) do |contents|
      files.zip(contents).each do |file, content|
        f = File.new(File.join(@tmp_dir, file), 'a+')
        f.write(content)
        f.flush
        f.close
      end
    end

    after do
      Dir.chdir(@pwd)
      FileUtils.rm_rf(@tmp_dir)
    end
  end
end
