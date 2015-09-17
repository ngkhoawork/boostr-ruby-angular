namespace :counter_cache_reset do
  desc 'Reset the counter caches'
  task reset_counter_cache: :environment do
    Client.all.each { |client| Client.reset_counters(client.id, :contacts) }
    Client.all.each { |client| Client.reset_counters(client.id, :agency_deals) }
    Client.all.each { |client| Client.reset_counters(client.id, :advertiser_deals) }
    puts '--> Client counter cache was successfully reset.'

    Stage.all.each { |stage| Stage.reset_counters(stage.id, :deals) }
    puts '--> Stage counter cache was successfully reset.'
  end

  task all: [:reset_counter_cache] do
    # This will run after all those tasks have run
  end
end
