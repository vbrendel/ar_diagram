namespace :ar_diagram do
  desc 'Migrates the db_diagram database'
  task :migrate => :environment do
    config = {
        :adapter => "sqlite3",
        :database => "db/ar_diagram.sqlite3"
    }
    @migration_path = File.expand_path("../../../db/migrate/ar_diagram", __FILE__)
    puts "Migrating from directory: #{@migration_path}"
    ActiveRecord::Base.establish_connection config
    ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
    ActiveRecord::Migrator.migrate(@migration_path, ENV["VERSION"] ? ENV["VERSION"].to_i : nil) do |migration|
      ENV["SCOPE"].blank? || (ENV["SCOPE"] == migration.scope)
    end
  end
end
