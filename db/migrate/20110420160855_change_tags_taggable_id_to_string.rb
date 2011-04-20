class ChangeTagsTaggableIdToString < ActiveRecord::Migration
  def self.up
    change_column :taggings, :taggable_id, :string
  end

  def self.down
  end
end
