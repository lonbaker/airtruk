%w{ rubygems sinatra sqlite3 active_record haml sass }.each do |lib|
  require lib
end

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'lib')

