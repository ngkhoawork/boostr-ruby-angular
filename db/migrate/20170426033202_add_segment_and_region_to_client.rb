class AddSegmentAndRegionToClient < ActiveRecord::Migration
  def change
    Company.all.each do |company|
      company.fields.find_or_initialize_by(subject_type: 'Client', name: 'Region', value_type: 'Option', locked: true)
      company.fields.find_or_initialize_by(subject_type: 'Client', name: 'Segment', value_type: 'Option', locked: true)
      company.save
    end
  end
end
