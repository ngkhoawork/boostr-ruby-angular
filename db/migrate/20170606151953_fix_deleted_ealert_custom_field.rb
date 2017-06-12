class FixDeletedEalertCustomField < ActiveRecord::Migration
  def change
    EalertCustomField.all.each do |ealert_custom_field|
      if ealert_custom_field.subject.nil?
        ealert_custom_field.destroy
      end
    end
  end
end
