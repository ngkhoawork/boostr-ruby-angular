class AddContactOptionField < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        Company.all.each do |company|
          company.fields.find_or_initialize_by(subject_type: 'Contact', name: 'Job Level', value_type: 'Option', locked: true)
          company.save
        end
      end

      dir.down do
        Company.all.each do |company|
          company.fields.where(subject_type: 'Contact', name: 'Job Level', value_type: 'Option', locked: true).destroy_all
        end
      end
    end
  end
end
