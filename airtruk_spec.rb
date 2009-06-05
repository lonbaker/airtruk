ENV['RACK_ENV'] = 'test' # for some reason, set does not work...

require 'app'
require 'spec'
require 'spec/interop/test'
require 'rack/test'

def app
  Sinatra::Application
end

describe 'Airtruk Network Configurator' do
  include Rack::Test::Methods
  
  before(:all) do
    system("rake db:migrate > /dev/null 2>&1")
  end
  
  before(:each) do
    Machine.delete_all
    ShellScript.delete_all
  end
  
  after(:all) do
    File.unlink(File.join(File.dirname(__FILE__), 'db', 'test.sqlite3'))
  end
  
  it 'shows launch page' do
    get '/'
    last_response.should be_ok
  end
  
  it 'can create only unique machines' do
    hname = 'somerandomhostname'
    mcount = Machine.count
    Machine.create :hostname => hname
    Machine.count.should == mcount + 1
    Machine.create :hostname => hname
    Machine.count.should == mcount + 1
  end
  
  it 'should have contents in a shell script' do
    sscount = ShellScript.count
    ShellScript.create :filename => '/etc/resolv.conf', :contents => 'blarg!', :configuration_name => 'sample config 1'
    ShellScript.count.should == sscount + 1
    ShellScript.create :filename => '/etc/resolv.conf', :contents => nil
    ShellScript.count.should == sscount + 1
  end
  
  it 'should have has_and_belongs_to_many associations' do
    m = Machine.create :hostname => 'maia'
    ss = ShellScript.create :filename => '/etc/passwd', :contents => 'someuser:x:/home/someuser::::', :configuration_name => 'system accounts'
    m.shell_scripts << ss
    m.shell_scripts.size.should == 1
    ss.machines.size.should == 1
  end
  
  it 'should have executable shell scripts' do
    ss = ShellScript.create :filename => nil, :contents => "#!/bin/bash\necho hello world!", :configuration_name => 'hello world'
    ShellScript.executable.size.should == 1
  end
  
  it 'should have replaceable shell scripts' do
    ss = ShellScript.create :filename => '/etc/resolv.conf', :contents => "nameserver 192.168.1.1\ndomain olympus\nsearch olympus", :configuration_name => 'dns configuration'
    ShellScript.replaceable.size.should == 1
  end
  
  it 'can create a new machine' do
    get '/machines/new'
    last_response.should be_ok
    mcount = Machine.count
    post '/machines', { :machine => { :hostname => 'foobarbaz' } }
    Machine.count.should == mcount + 1
    last_response['Location'].should == '/'
  end
  
  it 'can update and destroy an existing machine' do
    m = Machine.create :hostname => 'foobarbaz'
    murl = "/machines/#{m.id}"
    get murl
    last_response.should be_ok
    put murl, { :machine => { :hostname => 'newhostname' } }
    m.reload
    m.hostname.should == 'newhostname'
    last_response['Location'].should == '/'
    delete murl
    Machine.find_by_id(m.id).should == nil
    last_response['Location'].should == '/'
  end
  
  it 'can create a new shell script' do
    get '/shell_scripts/new'
    last_response.should be_ok
    sscount = ShellScript.count
    post '/shell_scripts', { :shell_script => { :filename => 'foobarbaz', :contents => 'filecontents', :configuration_name => 'sample config' } }
    ShellScript.count.should == sscount + 1
    last_response['Location'].should == '/'
  end
  
  it 'can update and destroy an existing shell script' do
    s = ShellScript.create :filename => 'foobarbaz', :configuration_name => 'sampleconfig', :contents => 'filecontent'
    surl = "/shell_scripts/#{s.id}"
    get surl
    last_response.should be_ok
    put surl, { :shell_script => { :filename => 'newfilename' } }
    s.reload
    s.filename.should == 'newfilename'
    last_response['Location'].should == '/'
    delete surl
    ShellScript.find_by_id(s.id).should == nil
    last_response['Location'].should == '/'
  end
  
  it 'can request a configuration script for a machine' do
    m = Machine.create :hostname => 'localhost'
    s = ShellScript.create :contents => 'echo hello world!', :configuration_name => 'hello world'
    m.shell_scripts << s
    get "/autoscript/#{m.hostname}"
    last_response.should be_ok
    last_response.body.should == "#!/bin/bash\necho hello world!"
  end
  
  it 'can add and remove a shell script from a machine' do
    m = Machine.create :hostname => 'localhost'
    s = ShellScript.create :contents => 'echo hello world!', :configuration_name => 'hello world'
    get "/add_shell_script/#{m.id}/#{s.id}"
    m.shell_scripts.reload
    m.shell_scripts.include?(s).should == true
    get "/remove_shell_script/#{m.id}/#{s.id}"
    m.shell_scripts.reload
    m.shell_scripts.include?(s).should == false
  end
end

