class Notification < ActiveRecord::Base
  belongs_to  :user
  serialize   :senders, Array
end
