##
# This is a file used to represent some configuration options on the target
# Machine. There are two basic things you can do with a file: run it or
# replace it. If you leave the 'filename' blank, it is executed, otherwise
# it is replaced. If you provide an owner field, it will chown afterwards.
# if you provide a mode, it will chmod it afterwards.
#
class ShellScript < ActiveRecord::Base
  named_scope :alphabetical, :order => 'configuration_name ASC'
  named_scope :executable, :conditions => 'filename IS NULL'
  named_scope :replaceable, :conditions => 'filename IS NOT NULL'
  has_and_belongs_to_many :machines
  validates_presence_of :configuration_name
  validates_uniqueness_of :configuration_name
  validates_presence_of :contents
end
