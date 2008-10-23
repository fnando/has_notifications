require "spec_helper"

# unset models used for testing purposes
Object.unset_class('User')

class Notify::Senders::Mail < Notify::Base
  def deliver
    $notifications << 'mail'
    $options = @options
  end
end

class Notify::Senders::Jabber < Notify::Base
  def deliver
    $notifications << 'jabber'
    $options = @options
  end
end

class Notify::Senders::Inbox < Notify::Base
  def deliver
    $notifications << 'inbox'
    $options = @options
  end
end

class User < ActiveRecord::Base
  has_many :notifications, :dependent => :destroy
end

describe "has_notifications" do
  before(:each) do
    $notifications = []
    $options = nil
    @user = User.create(:login => 'johndoe')
  end
  
  it "should create notification" do
    doing { 
      create_notification
    }.should_not raise_error
  end
  
  it "should serialize senders" do
    notification = create_notification
    notification.senders.should == %w(inbox mail jabber)
  end
  
  it "should send to mail only" do
    notification = create_notification(:senders => %w(mail))
    Notify.deliver(:name => 'friendship_invitation', :user => @user)
    $notifications.should == %w(mail)
  end
  
  it "should send to mail and jabber" do
    notification = create_notification(:senders => %w(mail jabber))
    Notify.deliver(:name => 'friendship_invitation', :user => @user)
    $notifications.should == %w(mail jabber)
  end
  
  it "should not send at all" do
    Notify.deliver(:name => 'friendship_invitation', :user => @user)
    $notifications.should be_empty
  end
  
  it "should set options" do
    create_notification(:senders => %w(jabber))
    Notify.deliver(:name => 'friendship_invitation', :user => @user, :some_data => 'some_data')
    $options.should == {:user => @user, :name => 'friendship_invitation', :some_data => 'some_data'}
  end
  
  it "should raise if user is not set" do
    doing {
      Notify.deliver(:name => 'friendship_invitation')
    }.should raise_error(ArgumentError)
  end
  
  it "should raise if name is not set" do
    doing {
      Notify.deliver(:user => @user)
    }.should raise_error(ArgumentError)
  end
  
  it "should not invoke invalid name" do
    Notify.deliver(:name => 'invalid', :user => @user)
  end
  
  it "should not invoke invalid senders" do
    create_notification(:senders => %w(invalid))
    Notify.deliver(:name => 'friendship_invitation', :user => @user)
    $notifications.should == []
  end
  
  it "should invoke only valid senders" do
    create_notification(:senders => %w(invalid mail))
    Notify.deliver(:name => 'friendship_invitation', :user => @user)
    $notifications.should == %w(mail)
  end
  
  private
    def create_notification(options={})
      @user.notifications.create!({
        :name => 'friendship_invitation', 
        :senders => %w(inbox mail jabber)
      }.merge(options))
    end
end