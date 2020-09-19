namespace :reports do
  desc "build time locking period for users"
  task clean_up: :environment do
    time = Time.now
    ReportsCleaner.new.perform
    puts "Task was finished for #{ (Time.now - time).round } seconds"
  end
end
