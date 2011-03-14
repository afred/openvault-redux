class CreateDatasets < ActiveRecord::Migration
  def self.up
    create_table :datasets do |t|
      t.string :name
      t.string :description
      t.string :format
      t.string :status
      t.datetime :due_at

      t.string :attachment_file_name
      t.string :attachment_content_type
      t.integer :attachment_file_size
      t.datetime :attachment_updated_at

      t.references :user

      t.timestamps
    end
  end

  def self.down
    drop_table :datasets
  end
end
