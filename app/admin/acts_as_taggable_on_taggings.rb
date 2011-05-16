ActiveAdmin.register ActsAsTaggableOn::Tagging do
  index do
    column "Tag" do |t|
      t.tag.name
    end
    column :taggable_id
    default_actions
  end
  
end
