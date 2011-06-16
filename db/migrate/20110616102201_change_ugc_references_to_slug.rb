class ChangeUgcReferencesToSlug < ActiveRecord::Migration 
  def self.up
    Comment.find_each do |a|
      response = Blacklight.solr.find :fq => "{!raw f=pid_s}#{a.commentable_id}", :fl => 'id'
      next unless response.docs.length == 1
      a.commentable_id = response.docs.first.id
      a.commentable_type = 'SolrDocument'
      a.save(false)
    end

    Tagging.find_each do |a|
      response = Blacklight.solr.find :fq => "{!raw f=pid_s}#{a.taggable_id}", :fl => 'id'
      next unless response.docs.length == 1
      a.taggable_id = response.docs.first.id
      a.taggable_type = 'SolrDocument'
      a.save(false)
    end

    #Bookmark.find_each do |a|
    #  response = Blacklight.solr.find :fq => "{!raw f=pid_s}#{a.document_id}", :fl => 'id'
    #  next unless response.docs.length == 1
    #  Comment.create :commentable_id => response.docs.first.id, :commentable_type => 'SolrDocument', :user => a.user, :comment => "Bookmarked.", :public => false, :created_at => a.created_at
    # end
  end

  def self.down

  end
end
