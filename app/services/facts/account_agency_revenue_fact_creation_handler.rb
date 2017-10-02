class Facts::AccountAgencyRevenueFactCreationHandler < BaseService
  def self.perform(params)
    self.new(params).tap do |instance|
      instance.find_or_create_records
      instance.delete_unused_records
    end
  end

  def delete_unused_records
    return if unused_records.blank?
    unused_records.delete_all
  end

  def find_or_create_records
    calculated_facts.each do |fact|
      find_or_update_fact(fact)
    end
  end

  private

  def unused_records
    AdvertiserAgencyRevenueFact.where('time_dimension_id = :time_dimension_id AND process_ran_at < :process_date_time',
                                      time_dimension_id: time_dimension.id, process_date_time: running_process_date_time)

  end

  def running_process_date_time
    @running_process_date_time ||= DateTime.now
  end

  def find_or_update_fact(calculated_record)
    fact = AdvertiserAgencyRevenueFact.find_or_initialize_by(advertiser_id: calculated_record.advertiser_id,
                                                             agency_id: calculated_record.agency_id,
                                                             company_id: calculated_record.company_id,
                                                             time_dimension_id: time_dimension.id)
    if fact.persisted? && fact.revenue_amount != calculated_record.revenue_amount.to_i
      fact.update_attributes(revenue_amount: calculated_record.revenue_amount.to_i,
                             process_ran_at: running_process_date_time)
    elsif fact.new_record?
      fact.update_attributes(revenue_amount: calculated_record.revenue_amount.to_i,
                             process_ran_at: running_process_date_time)
    end
  end
end