##
# Reprsents a host on a network that receives Configuration profiles
# from a set defined in the application.
#
class Machine < ActiveRecord::Base
  validates_presence_of :hostname
  validates_uniqueness_of :hostname
  has_and_belongs_to_many :shell_scripts

  ##
  # Generates the automatic script for this host. First concats all
  # of the executable scripts, then the replacable files.
  #
  def autoscript
    res = []
    self.shell_scripts.executable.each do |s|
      res << s.contents
    end
    self.shell_scripts.replaceable.each do |s|
      res << "cat <<EOF > #{s.filename}\n#{s.contents.gsub(/\r/, '')}\nEOF"
      res << "chown #{s.owner} #{s.filename}" unless s.owner.to_s.empty?
      res << "chmod #{s.mode} #{s.filename}" unless s.mode.to_s.empty?
    end
    "#!/bin/bash\n#{res.join("\n")}"
  end
end
