has_notifications
=================

This plugin was created to act as a proxy between different notification 
systems based on the user's preferences. IT DOESN'T IMPLEMENT ANY NOTIFICATION 
SYSTEM.

**WORK IN PROGRESS:** I wrote this code without running any code, some 
probably won't work! This is called _blind faith programming_! :P

Instalation
-----------

1) Install the plugin with `script/plugin install git://github.com/fnando/has_notifications.git`

2) Generate a migration with `script/generate migration create_notifications` and add the following code:

	class CreateNotifications < ActiveRecord::Migration
	  def self.up
	    create_table :notifications do |t|
	      t.references	:user
	      t.string		:name
	      t.text		:senders
	    end
    
	    add_index :notifications, :user_id
	    add_index :notifications, :name
	  end

	  def self.down
	    drop_table :notifications
	  end
	end

3) Run the migrations with `rake db:migrate`

Usage
-----

1) Add association below to the User model:

	class User < ActiveRecord::Base
	  has_many :notifications, :dependent => :destroy
	end

2) Create user preferences for a specific notification

	# create a new notification setting, specifying which
	# senders will be associated
	notification = @user.notifications.create({
		:name => 'friendship_request',
		:senders => %w(mail jabber)
	})

	# deliver some message
	Notify.deliver({
		:name => 'friendship_request, 
		:user => @user, 
		:friendship => @friendship
	})

3) To implement a sender, you need to add a class to the module 
`Notify::Senders`. Check this example, that implements notification by mail 
using [mail_queue](http://github.com/fnando/mail_queue)

    # lib/senders/mail.rb
    class Notify::Senders::Mail < Notify::Base
      def deliver
        Mailer.queue(:some_email, @options)
      end
    end

    # lib/senders/jabber.rb
    class Notify::Senders::Jabber < Notify::Base
      def deliver
        # using xmpp4r-simple set somewhere
        JABBER.deliver(@options[:user].jid, 
          "You have new friendship request. Visit http://example.com/friends/pending"
        )
      end
    end

A sender should have a `deliver` method. The options hash is set as instance 
attribute named `@options`.

TO-DO
-----

* Check if is working
* Write specs

Copyright (c) 2008 Nando Vieira, released under the MIT license
