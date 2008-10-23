ActiveRecord::Schema.define(:version => 0) do
  create_table :users do |t|
    t.string :login
  end
  
  create_table :notifications do |t|
    t.references  :user
    t.string      :name
    t.text        :senders
  end
end