class InfluencerContentFee < ActiveRecord::Base
  belongs_to :influencer
  belongs_to :content_fee
  has_one :currency, class_name: 'Currency', primary_key: 'curr_cd', foreign_key: 'curr_cd'

  before_create do
    update_net
    exchange_amount
  end
  before_update do
    update_net
    exchange_amount
  end

  scope :for_influencer_id, -> (influencer_id) { where(influencer_id: influencer_id) if influencer_id.present? }
  scope :by_effect_date, -> (start_date, end_date) do
    where(effect_date: start_date..end_date) if start_date.present? && end_date.present?
  end

  def update_net
    if influencer.agreement.present?
      fee_amount = self.fee_amount
      fee_amount_loc = (fee_amount || 0) / self.exchange_rate if self.exchange_rate && self.fee_type == 'flat'
      if self.fee_type && self.fee_type == 'flat'
        self.net_loc = fee_amount_loc
      elsif self.fee_type && self.fee_type == 'percentage'
        self.net_loc = (fee_amount || 0) * self.gross_amount_loc / 100.0
      end
    end
  end

  def exchange_amount
    exchange_rate = self.exchange_rate
    if exchange_rate
      self.gross_amount = (self.gross_amount_loc.to_f * exchange_rate).round(2)
      self.net = (self.net_loc.to_f * exchange_rate).round(2)
      self.fee_amount_loc = (self.fee_amount.to_f / exchange_rate).round(2) if self.fee_type == 'flat'
    end
  end

  def exchange_rate
    self.influencer.company.exchange_rate_for(at_date: self.content_fee.io.created_at, currency: self.curr_cd)
  end

  def team_name
    team = nil
    if content_fee.io.highest_member.present? 
      user = content_fee.io.highest_member.user
      if user && user.leader?
        team = user.teams.first
      elsif user
        team = user.team
      end
    end
    if team
      team.name
    else
      ''
    end
  end

  def self.import(file, current_user_id, file_path)
    current_user = User.find current_user_id

    import_log = CsvImportLog.new(company_id: current_user.company_id, object_name: 'influencer_content_fee', source: 'ui')
    import_log.set_file_source(file_path)
    
    CSV.parse(file, headers: true) do |row|
      import_log.count_processed
      
      if row[0].nil? || row[0].blank?
        import_log.count_failed
        import_log.log_error(['IO Number is empty'])
        next
      end

      if row[1].nil? || row[1].blank?
        import_log.count_failed
        import_log.log_error(['Influencer ID is empty'])
        next
      end

      if row[2].nil? || row[2].blank?
        import_log.count_failed
        import_log.log_error(['Product Name is empty'])
        next
      end

      if row[3].nil? || row[3].blank?
        import_log.count_failed
        import_log.log_error(['Date is empty'])
        next
      end

      if row[6].nil? || row[6].blank?
        import_log.count_failed
        import_log.log_error(['Gross is empty'])
        next
      end

      unless io = current_user.company.ios.find_by(io_number:row[0])
        import_log.count_failed
        import_log.log_error(['IO Number ' + row[0].to_s + ' could not be found'])
        next
      end

      unless influencer = current_user.company.influencers.find_by(id:row[1])
        import_log.count_failed
        import_log.log_error(['Influencer with ' + row[0].to_s + ' id could not be found'])
        next
      end

      unless product = io.content_fee_products.find_by(name:row[2])
        import_log.count_failed
        import_log.log_error(['Influencer Product with ' + row[2].to_s + ' name could not be found'])
        next
      end

      effect_date = nil
      if row[3].present?
        begin
          effect_date = Date.strptime(row[3].strip, "%d/%m/%Y")
          if io.end_date.year < 100
            io.end_date = Date.strptime(row[3].strip, "%d/%m/%y")
          end
        rescue ArgumentError
          import_log.count_failed
          import_log.log_error(['IO End Date must be a valid datetime'])
          next
        end
      else
        import_log.count_failed
        import_log.log_error(['Date must be present'])
        next
      end

      if effect_date && !(effect_date >=io.start_date && effect_date <= io.end_date)
        import_log.count_failed
        import_log.log_error(['Date must be between IO start and end dates'])
        next
      end

      if row[4]
        if row[4] == 'percentage' || row[4] == 'flat'
          fee_type = row[4]
        else
          import_log.count_failed
          import_log.log_error(['Fee type should be either \'percentage\' or \'flat\'.'])
          next
        end
      else
        fee_type = influencer.agreement.fee_type if influencer.agreement.present?
      end
      
      if row[5]
        fee_amount_loc = Integer(row[5].strip) rescue false
        unless fee_amount_loc
          import_log.count_failed
          import_log.log_error(["Fee amount # must be a numeric value"])
          next
        end
      else
        fee_amount_loc = influencer.agreement.amount if influencer.agreement.present?
      end
      
      unless content_fee = io.content_fees.find_by(product_id: product.id)
        import_log.count_failed
        import_log.log_error(['Content fee for specified io and product could not be found'])
        next
      end

      influencer_content_fee = InfluencerContentFee.create({influencer_id: current_user.company_id, address_attributes: {email: row[3]}})
       contact_params[:id] = contact.id
      
      if influencer_content_fee
        import_log.count_imported
      else
        import_log.count_failed
        import_log.log_error(influencer_content_fee.errors.full_messages)
        next
      end
    end

    import_log.save
  end
end
