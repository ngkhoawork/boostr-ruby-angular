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
      
      io_number = row[0]
      if io_number.nil? || io_number.blank?
        import_log.count_failed
        import_log.log_error(['IO Number is empty'])
        next
      end
      
      influencer_id = row[1]
      if influencer_id.nil? || influencer_id.blank?
        import_log.count_failed
        import_log.log_error(['Influencer ID is empty'])
        next
      end

      product_name = row[2]
      if product_name.nil? || product_name.blank?
        import_log.count_failed
        import_log.log_error(['Product Name is empty'])
        next
      end

      effect_date = nil
      if row[3].present?
        begin
          effect_date = Date.strptime(row[3].strip, "%d/%m/%Y")
          if effect_date.year < 100
            effect_date = Date.strptime(row[3].strip, "%d/%m/%y")
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

      gross = row[6]
      if gross.nil? || gross.blank?
        import_log.count_failed
        import_log.log_error(['Gross is empty'])
        next
      end

      unless io = current_user.company.ios.find_by(io_number: io_number)
        import_log.count_failed
        import_log.log_error(['IO Number with ' + io_number.to_s + ' could not be found'])
        next
      end

      unless influencer = current_user.company.influencers.find_by(id: influencer_id)
        import_log.count_failed
        import_log.log_error(['Influencer with id ' + influencer_id.to_s + ' could not be found'])
        next
      end

      unless product = io.content_fee_products.find_by(name: product_name)
        import_log.count_failed
        import_log.log_error(['Influencer Product with name ' + product_name.to_s + ' could not be found'])
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

      if fee_type == 'flat' && io.exchange_rate.present?
        fee_amount = (fee_amount_loc.to_f * io.exchange_rate).round(2)
      else
        fee_amount = fee_amount_loc
      end

      influencer_content_fee_param = {
        influencer_id: influencer_id,
        content_fee_id: content_fee.id,
        fee_type: fee_type,
        fee_amount: fee_amount,
        effect_date: effect_date,
        curr_cd: io.curr_cd,
        gross_amount_loc: gross,
        asset: row[7].strip
      }

      influencer_content_fee = InfluencerContentFee.create(influencer_content_fee_param)
      
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
