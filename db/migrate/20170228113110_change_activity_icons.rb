class ChangeActivityIcons < ActiveRecord::Migration
  def change
    Company.all.find_each do |company|
      activity_types_arr = [
        { name:'Initial Meeting', action:'had initial meeting with', icon:'/assets/icons/initial-meeting.png' },
        { name:'Pitch', action:'pitched to', icon:'/assets/icons/pitch.png' },
        { name:'Proposal', action:'sent proposal to', icon:'/assets/icons/proposal.png' },
        { name:'Feedback', action:'received feedback from', icon:'/assets/icons/feedback.png' },
        { name:'Agency Meeting', action:'had agency meeting with', icon:'/assets/icons/agency-meeting.png' },
        { name:'Client Meeting', action:'had client meeting with', icon:'/assets/icons/client-meeting.png' },
        { name:'Entertainment', action:'had client entertainment with', icon:'/assets/icons/entertainment.png' },
        { name:'Campaign Review', action:'reviewed campaign with', icon:'/assets/icons/campaign-review.png' },
        { name:'QBR', action:'Quarterly Business Review with', icon:'/assets/icons/qbr.png' },
        { name:'Email', action:'emailed to', icon:'/assets/icons/email.png' },
        { name:'Post Sale Meeting', action:'had post sale meeting with', icon:'/assets/icons/post-sale.png' }
      ]

      activity_types_arr.each do |type_hash|
        company.activity_types
        .find_or_initialize_by(name: type_hash[:name], action: type_hash[:action])
        .update(icon: type_hash[:icon])
      end
    end
  end
end
