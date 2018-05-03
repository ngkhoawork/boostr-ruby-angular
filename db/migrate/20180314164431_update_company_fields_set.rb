class UpdateCompanyFieldsSet < ActiveRecord::Migration
  def up
    Company.find_each do |company|
      begin
        company.send(:setup_defaults)
        company.save(validate: false)
      rescue
        raise ActiveRecord::Rollback
      end
    end
  end
end
