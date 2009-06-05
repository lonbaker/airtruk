%w{ rubygems sinatra haml sass active_record sqlite3 }.each do |lib|
  require lib
end

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'lib')

begin
  dbf = File.join(File.dirname(__FILE__), 'config', 'database.yml')
  dbconfig = YAML::load_file(dbf)[Sinatra::Application.environment.to_s]
  ActiveRecord::Base.establish_connection(dbconfig)
rescue => exception
  $stderr.puts "There was a problem connecting to the database:"
  $stderr.puts "* #{exception.message}"
  exception.backtrace.each do |msg|
    $stderr.puts "-> #{msg}"
  end
  exit 1
end

