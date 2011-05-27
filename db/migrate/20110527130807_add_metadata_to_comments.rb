class AddMetadataToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :metadata, :text
    add_column :comments, :public, :boolean
  end

  def self.down
    remove_column :comments, :public
    remove_column :comments, :metadata
  end
end
