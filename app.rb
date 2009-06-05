#!/usr/bin/env ruby
#
# Airtruk -- It saved everybody after the ThunderDome
#
# Used to feed configuration to a set of hosts on a network.
#

%w{ rubygems sinatra sqlite3 active_record haml sass }.each do |lib|
  require lib
end

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'lib')

configure do
  %w{ active_record_connect machine shell_script }.each do |lib|
    require lib
  end
end

configure :development do
  set :logging, true
  ActiveRecord::Base.logger = Logger.new($stderr)
end 

get '/' do
  @machines = Machine.find :all, :order => 'hostname ASC', :include => :shell_scripts
  @shell_scripts = ShellScript.alphabetical
  haml :index
end

get '/machines/new' do
  @machine = Machine.new
  haml :machine_edit
end

get '/machines/:id' do
  @machine = Machine.find(params[:id])
  haml :machine_edit
end

post '/machines' do
  @machine = Machine.new(params[:machine])
  if @machine.save
    redirect '/'
  else
    haml :machine_edit
  end
end

put '/machines/:id' do
  @machine = Machine.find(params[:id])
  if @machine.update_attributes params[:machine]
    redirect '/'
  else
    haml :machine_edit
  end
end

delete '/machines/:id' do
  @machine = Machine.find(params[:id])
  @machine.destroy
  redirect '/'
end

get '/shell_scripts/new' do
  @shell_script = ShellScript.new
  haml :shell_script_edit
end

get '/shell_scripts/:id' do
  @shell_script = ShellScript.find(params[:id])
  haml :shell_script_edit
end

post '/shell_scripts' do
  @shell_script = ShellScript.new(params[:shell_script])
  if @shell_script.save
    redirect '/'
  else
    haml :shell_script_edit
  end
end

put '/shell_scripts/:id' do
  @shell_script = ShellScript.find(params[:id])
  if @shell_script.update_attributes(params[:shell_script])
    redirect '/'
  else
    haml :shell_script_edit
  end
end

delete '/shell_scripts/:id' do
  @shell_script = ShellScript.find(params[:id])
  @shell_script.destroy
  redirect '/'
end

get '/autoscript/:hostname' do
  @machine = Machine.find_by_hostname(params[:hostname], :include => :shell_scripts)
  content_type 'text/plain'
  attachment 'autoscript.sh'
  body @machine.autoscript
end

get '/add_shell_script/:machine_id/:shell_script_id' do
  machine = Machine.find(params[:machine_id])
  shell_script = ShellScript.find(params[:shell_script_id])
  machine.shell_scripts << shell_script
  redirect '/'
end

get '/remove_shell_script/:machine_id/:shell_script_id' do
  machine = Machine.find(params[:machine_id])
  shell_script = ShellScript.find(params[:shell_script_id])
  machine.shell_scripts.delete(shell_script)
  redirect '/'
end

use_in_file_templates!

__END__

@@ layout
%html
  %head
    %title AirTruk Configuration
    %style{ :type => 'text/css' }
      :sass
        a
          img
            border: none
        td
          text-align: center
  %body
    = yield
@@ index

%h1#title== Now serving #{Machine.count} machines with #{ShellScript.count} shell scripts!

%p#navigation
  %a{ :href => '/machines/new', :title => 'New Machine' } New Machine
  |
  %a{ :href => '/shell_scripts/new', :title => 'New Shell Script' } New Shell Script

%table#configuration
  %tr
    %th &nbsp;
    %th &nbsp;
    - @shell_scripts.each do |shell_script|
      %th
        %a{ :href => "/shell_scripts/#{shell_script.id}", :title => "Edit shell script" }= shell_script.configuration_name
  - @machines.each do |machine|
    %tr
      %td
        %a{ :href => "/autoscript/#{machine.hostname}", :title => "Configuration for #{machine.hostname}" }= machine.hostname
      %td
        %a{ :href => "/machines/#{machine.id}", :title => "Update machine settings" } (edit)
      - @shell_scripts.each do |shell_script|
        %td
          - if machine.shell_scripts.include?(shell_script)
            %a{ :href => "/remove_shell_script/#{machine.id}/#{shell_script.id}", :title => "Remove #{shell_script.configuration_name} from #{machine.hostname}", :rel => "nofollow" }
              %img{ :src => '/list-remove.png' }
          - else
            %a{ :href => "/add_shell_script/#{machine.id}/#{shell_script.id}", :title => "Add #{shell_script.configuration_name} to #{machine.hostname}", :rel => "nofollow" }
              %img{ :src => '/list-add.png' }

%p#footer
  Learn more about the
  %a{ :href => 'http://en.wikipedia.org/wiki/Transavia_PL-12_Airtruk', :title => 'Transavia PL-12 Airtruk', :onclick => 'window.open(this.href);return false;' } Transavia PL-12 Airtruk
  aircraft used in
  %a{ :href => 'http://en.wikipedia.org/wiki/Mad_Max_Beyond_Thunderdome', :title => 'Mad Max Beyond Thunderdome', :onclick => 'window.open(this.href);return false;' } Mad Max Beyond Thunderdome.
  %br
  &copy; 2009
  %a{ :href => 'http://github.com/penguincoder', :onclick => 'window.open(this.href);return false;' } Andrew Coleman
  except the Airtruk.

@@ machine_edit
%p
  %a{ :href => '/', :title => 'Configurator' } Configurator
  - unless @machine.new_record?
    |
    %a{ :href => "/machines/#{@machine.id}", :title => "Destroy machine", :onclick => "if(confirm('Are you sure?')){var f = document.createElement('form'); f.style.display = 'none'; this.parentNode.appendChild(f); f.method = 'POST'; f.action = this.href;var m = document.createElement('input'); m.setAttribute('type', 'hidden'); m.setAttribute('name', '_method'); m.setAttribute('value', 'delete'); f.appendChild(m);f.submit();return false;}" } Destroy Machine


- if @machine.new_record?
  %form{ :action => '/machines', :method => 'post' }
    = haml :machine_form
    %input{ :type => 'submit', :value => 'Create' }
- else
  %form{ :action => "/machines/#{@machine.id}", :method => 'post' }
    %input{ :type => 'hidden', :name => '_method', :value => 'put' }
    = haml :machine_form
    %input{ :type => 'submit', :value => 'Update' }

@@ machine_form
%fieldset
  %p
    %label
      Hostname
      %input{ :type => 'text', :name => 'machine[hostname]', :size => 50, :maxsize => 255, :value => @machine.hostname }

@@ shell_script_edit
%p
  %a{ :href => '/', :title => 'Configurator' } Configurator
  - unless @shell_script.new_record?
    |
    %a{ :href => "/shell_scripts/#{@shell_script.id}", :title => "Destroy shell script", :onclick => "if(confirm('Are you sure?')){var f = document.createElement('form'); f.style.display = 'none'; this.parentNode.appendChild(f); f.method = 'POST'; f.action = this.href;var m = document.createElement('input'); m.setAttribute('type', 'hidden'); m.setAttribute('name', '_method'); m.setAttribute('value', 'delete'); f.appendChild(m);f.submit();return false;}" } Destroy Shell Script

- if @shell_script.new_record?
  %form{ :action => '/shell_scripts', :method => 'post' }
    = haml :shell_script_form
    %input{ :type => 'submit', :value => 'Create' }
- else
  %form{ :action => "/shell_scripts/#{@shell_script.id}", :method => 'post' }
    %input{ :type => 'hidden', :name => '_method', :value => 'put' }
    = haml :shell_script_form
    %input{ :type => 'submit', :value => 'Update' }

@@ shell_script_form
%fieldset
  %p
    %label
      Configuration Name
      %input{ :type => 'text', :name => 'shell_script[configuration_name]', :size => 50, :maxsize => 255, :value => @shell_script.configuration_name }
    %br
    %small Required. Must be unique.
  %p
    %label
      Filename
      %input{ :type => 'text', :name => 'shell_script[filename]', :size => 50, :maxsize => 255, :value => @shell_script.filename }
    %br
    %small Leave the filename blank to execute the contents of the script.
  %p
    %label
      Owner/Group
      %input{ :type => 'text', :name => 'shell_script[owner]', :size => 50, :maxsize => 255, :value => @shell_script.owner }
    %br
    %small Passed directly to <code>chown</code>, you can also specify a group.
  %p
    %label
      Mode
      %input{ :type => 'text', :name => 'shell_script[mode]', :size => 50, :maxsize => 255, :value => @shell_script.mode }
    %br
    %small Passed directly to <code>chmod</code>.
  %p
    %label
      Contents
      %textarea{ :name => 'shell_script[contents]', :rows => 10, :cols => 40, :style => "font-family: Lucida Console, Courier New, Courier, Monospace;" }= @shell_script.contents

