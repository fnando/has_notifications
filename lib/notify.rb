module Notify
  def self.deliver(options)
    raise ArgumentError, ':name is required' unless options[:name]
    raise ArgumentError, ':user is required' unless options[:user]
    
    # retrieve the user's preferences, so is possible to decide which
    # senders will be instantiated
    prefs = options[:user].notifications.first(:conditions => {:name => options[:name].to_s})
    
    # no preferences for this key
    # return because user haven't set it yet
    return unless prefs
    
    # retrieve all available senders
    senders = Notify::Senders.constants
    
    # prepare user settings
    notifications = prefs.senders.collect(&:classify)
    
    # retrieve intersection between all available senders and
    # notifications chosen by the user
    senders_to_run = notifications & senders
    
    senders_to_run.each do |class_name|
      sender = Notify::Senders.const_get(class_name).new(options)
      sender.deliver
    end
  end
  
  class Base
    attr_accessor :options
    
    def initialize(options)
      @options = options
    end
  end
  
  module Senders
    # create your own senders by adding a class to Notify::Senders module;
    # your class should have a method called `deliver`
  end
end