class Egnyte::PrivateActions::SanitizeFolderName
  ALL_REPLACEMENT_SIGN = ' '.freeze
  EDGE_REPLACEMENT_SIGN = ''.freeze

  def self.perform(folder_name)
    new(folder_name).perform
  end

  def initialize(folder_name)
    @folder_name = folder_name.dup
  end

  def perform
    replace_all_str_forbidden_signs
    replace_start_str_forbidden_signs
    replace_end_str_forbidden_signs
  end

  private

  def replace_all_str_forbidden_signs
    @folder_name.gsub!(/[\\\/\|\*\?\+":<>]+/, ALL_REPLACEMENT_SIGN)
  end

  def replace_start_str_forbidden_signs
    @folder_name.gsub!(/\A[ ]+(?=\w)/, EDGE_REPLACEMENT_SIGN)
  end

  def replace_end_str_forbidden_signs
    @folder_name.gsub!(/(?<=\w)[ \.]+\z/, EDGE_REPLACEMENT_SIGN)
  end
end
