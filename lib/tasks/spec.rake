task(:spec).enhance do
  system('RAILS_ENV=test bundle exec rake spec:javascript')
end
