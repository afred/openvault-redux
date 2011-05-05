require_dependency( 'vendor/plugins/blacklight_user_generated_content/app/controllers/comments_controller.rb')

class CommentsController < ApplicationController
  def create
    if params[:comment][:commentable_type] == "SolrDocument"
      @response, @documents = get_solr_response_for_field_values("id",params[:comment][:commentable_id])
      @document = @documents.first
      if @document.surrogate
        params[:comment][:commentable_id] = @document.surrogate.id
        params[:comment][:commentable_type] = @document.surrogate.class.to_s
      end
    end

    @comment = Comment.new(params[:comment])
    @comment.user = current_user
    respond_to do |format|
      if @comment.save
        @document.save
        redirect_to catalog_comments_url(:catalog_id => @document.id) and return if @comment.commentable_type == "Surrogate" 
        format.html { redirect_to(@comment, :notice => 'Comment was successfully created.') }
        format.xml  { render :xml => @comment, :status => :created, :location => @comment }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
      end
    end
  end
end
