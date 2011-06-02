class AddProfileDataToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :postal_code, :string
    add_column :users, :country, :string
    add_column :users, :mla_updates, :boolean
    add_column :users, :terms_and_conditions, :boolean
  end

  def self.down
    remove_column :users, :mla_updates
    remove_column :users, :country
    remove_column :users, :postal_code
    remove_column :users, :last_name
    remove_column :users, :first_name
  end
end
