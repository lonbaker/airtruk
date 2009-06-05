# h/t http://adam.blog.heroku.com/past/2009/2/28/activerecord_migrations_outside_rails/
namespace :db do
  desc "Migrate the database"
  task :migrate do
    require 'app'
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.migrate("db/migrate")
  end
end

desc "Tests the application using RSpec"
task :test do
  system('spec airtruk_spec.rb')
end

task :default => :test

