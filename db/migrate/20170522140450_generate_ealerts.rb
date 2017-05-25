class GenerateEalerts < ActiveRecord::Migration
  def change
    Company.all.each do |company|
      ealert = Ealert.new({
        company_id: company.id,
        recipients: nil,
        automatic_send: false,
        same_all_stages: true
      })
      ealert.save()
    end
  end
end
