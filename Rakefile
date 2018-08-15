require 'rake/testtask'
require './lib/rounded_services'

config = RoundedServices::Config.instance

task "app:setup" do
  FileUtils.mkdir_p './log'
  FileUtils.mkdir_p './db/migrations'
end

# Rake::TestTask.new do |t|
#   t.pattern = "spec/squeaky/**/*_spec.rb"
#   t.verbose = true
# end

desc "Run Sequel Migrations for PG"
task "db:migrate" do
  exec("sequel -m db/migrations 'postgres://#{config.db_host}/#{config.db_name}?user=#{config.db_user}&password=#{config.db_password}'")
end

desc "Create Sequel Migration"
task "db:create_migration" do
  migration_name = ""
  ARGV.each { |a| task a.to_sym do ; end }
  ARGV.drop(1).each { |word| migration_name << "#{word}_" }
  migration_name << ".rb"
  migration_name.prepend("#{Time.now.to_i.to_s}_")
  FileUtils.touch("./db/migrations/#{migration_name}")
end
