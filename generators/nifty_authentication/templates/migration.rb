class Create<%= user_plural_class_name %> < ActiveRecord::Migration
  def self.up
    create_table :<%= user_plural_name %> do |t|
      t.string :username
      t.string :email
    <%- if options[:authlogic] -%>
      t.string :persistence_token
      t.string :crypted_password
      t.string :perishable_token, :null => false # optional, see Authlogic::Session::Perishability
      t.integer :login_count, :null => false, :default => 0 # optional, see Authlogic::Session::MagicColumns
      t.integer :failed_login_count, :null => false, :default => 0 # optional, see Authlogic::Session::MagicColumns
      t.datetime :last_request_at # optional, see Authlogic::Session::MagicColumns
      t.datetime :current_login_at # optional, see Authlogic::Session::MagicColumns
      t.datetime :last_login_at # optional, see Authlogic::Session::MagicColumns
    <%- else -%>
      t.string :password_hash
    <%- end -%>
      t.string :password_salt
      t.timestamps
    end
  end
  
  def self.down
    drop_table :<%= user_plural_name %>
  end
end
