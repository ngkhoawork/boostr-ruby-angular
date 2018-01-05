class UpdateEmptyCssClassInActivityTypes < ActiveRecord::Migration
  def change
    update_empty_css_classes
  end

  def update_empty_css_classes
      ActivityType.by_name('Initial Meeting').where(css_class: nil).update_all(css_class: 'bstr-initial-meeting')
      ActivityType.by_name('Pitch').where(css_class: nil).update_all(css_class: 'bstr-pitch')
      ActivityType.by_name('Proposal').where(css_class: nil).update_all(css_class: 'bstr-proposal')
      ActivityType.by_name('Feedback').where(css_class: nil).update_all(css_class: 'bstr-feedback')
      ActivityType.by_name('Agency Meeting').where(css_class: nil).update_all(css_class: 'bstr-agency-meeting')
      ActivityType.by_name('Client Meeting').where(css_class: nil).update_all(css_class: 'bstr-client-meeting')
      ActivityType.by_name('Entertainment').where(css_class: nil).update_all(css_class: 'bstr-entertainment')
      ActivityType.by_name('Campaign Review').where(css_class: nil).update_all(css_class: 'bstr-campaign-review')
      ActivityType.by_name('QBR').where(css_class: nil).update_all(css_class: 'bstr-qbr')
      ActivityType.by_name('Email').where(css_class: nil).update_all(css_class: 'bstr-email', editable: false)
      ActivityType.by_name('Post Sale Meeting').where(css_class: nil).update_all(css_class: 'bstr-post-sale-meeting')
      ActivityType.by_name('Internal Meeting').where(css_class: nil).update_all(css_class: 'bstr-internal-meeting')
    end
end
