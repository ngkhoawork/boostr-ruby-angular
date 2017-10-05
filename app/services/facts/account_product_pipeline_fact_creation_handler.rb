class Facts::AccountProductPipelineFactCreationHandler < BaseService
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
    AccountProductPipelineFact.where('time_dimension_id = :time_dimension_id AND process_ran_at < :process_date_time
                                      AND company_id = :company_id',
                                     time_dimension_id: time_dimension.id,
                                     process_date_time: running_process_date_time,
                                     company_id: company_id)
  end


  def running_process_date_time
    @running_process_date_time ||= DateTime.now
  end

  def find_or_update_fact(calculated_record)
    fact = AccountProductPipelineFact.find_or_initialize_by(account_dimension_id: calculated_record.account_dimension_id,
                                                            company_id: calculated_record.company_id,
                                                            time_dimension_id: time_dimension.id,
                                                            product_dimension_id: calculated_record.product_id)
    if fact.persisted? && fact.unweighted_amount != calculated_record.unweighted_amount.to_i
      fact.update_attributes(unweighted_amount: calculated_record.unweighted_amount.to_i,
                             weighted_amount:   calculated_record.weighted_amount.to_i,
                             process_ran_at:    running_process_date_time)
    elsif fact.new_record?
      fact.update_attributes(unweighted_amount: calculated_record.unweighted_amount.to_i,
                             weighted_amount:   calculated_record.weighted_amount.to_i,
                             process_ran_at:    running_process_date_time)
    else
      fact.update_attributes(process_ran_at: running_process_date_time)
    end
  end
end