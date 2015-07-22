Rake::Task[:default].clear
task default: :environment do
  system('rspec spec')
  system('RAILS_ENV=test rake spec:javascript')
end