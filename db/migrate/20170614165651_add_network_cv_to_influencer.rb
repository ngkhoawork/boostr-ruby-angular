class AddNetworkCvToInfluencer < ActiveRecord::Migration
  def change
    Company.all.each do |company|
      company.fields.find_or_initialize_by(subject_type: 'Influencer', name: 'Network', value_type: 'Option', locked: true)
      company.save
    end
  end
end
