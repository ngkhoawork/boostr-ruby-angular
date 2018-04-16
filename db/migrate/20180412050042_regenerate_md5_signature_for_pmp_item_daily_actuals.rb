class RegenerateMd5SignatureForPmpItemDailyActuals < ActiveRecord::Migration
  class PmpItemDailyActual < ActiveRecord::Base
    belongs_to :pmp_item

    def regenerate_md5_signature!
      return unless pmp_item

      update_attribute(
        :md5_signature, Digest::MD5.hexdigest("#{date}#{pmp_item.ssp_deal_id}#{ad_unit}#{ssp_advertiser}")
      )
    end
  end

  def change
    PmpItemDailyActual.find_each { |daily_actual| daily_actual.regenerate_md5_signature! }
  end
end
