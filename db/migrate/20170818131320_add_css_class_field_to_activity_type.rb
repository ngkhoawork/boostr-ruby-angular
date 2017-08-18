class AddCssClassFieldToActivityType < ActiveRecord::Migration
  def change
    add_column :activity_types, :css_class, :string
    add_column :activity_types, :editable, :boolean, default: true
    
    add_css_classes
  end

  def add_css_classes
    ActivityType.by_name('Initial Meeting').update_all(css_class: 'bstr-initial-meeting')
    ActivityType.by_name('Pitch').update_all(css_class: 'bstr-pitch')
    ActivityType.by_name('Proposal').update_all(css_class: 'bstr-proposal')
    ActivityType.by_name('Feedback').update_all(css_class: 'bstr-feedback')
    ActivityType.by_name('Agency Meeting').update_all(css_class: 'bstr-agency-meeting')
    ActivityType.by_name('Client Meeting').update_all(css_class: 'bstr-client-meeting')
    ActivityType.by_name('Entertainment').update_all(css_class: 'bstr-entertainment')
    ActivityType.by_name('Campaign Review').update_all(css_class: 'bstr-campaign-review')
    ActivityType.by_name('QBR').update_all(css_class: 'bstr-qbr')
    ActivityType.by_name('Email').update_all(css_class: 'bstr-email', editable: false)
    ActivityType.by_name('Post Sale Meeting').update_all(css_class: 'bstr-post-sale-meeting')
    ActivityType.by_name('Internal Meeting').update_all(css_class: 'bstr-initial-meeting')
  end
end
