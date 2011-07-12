class CommentsController < ApplicationController
  include Blacklight::SolrHelper
  load_and_authorize_resource

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to new_user_session_url(:referer => request.url, :no_layout => (1 if request.xhr?))
  end
  

  # GET /comments
  # GET /comments.xml
  def index
    if params[:catalog_id]
      @response, @documents = get_solr_response_for_field_values("id",params[:catalog_id])
      @document = @documents.first
    end

    @comments = @comments.where(:public => true) if params[:public]
    @comments = @comments.where(:commentable_id => @document.id, :commentable_type => @document.class.to_s) if @document
    @comments = @comments.where(:user_id => params[:user_id]) if params[:user_id]

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @comments }
    end
  end

  # GET /comments/1
  # GET /comments/1.xml
  def show
   # @comment = Comment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @comment }
    end
  end

  # GET /comments/new
  # GET /comments/new.xml
  def new
    @response, @documents = get_solr_response_for_field_values("id",params[:catalog_id])
    @document = @documents.first

    @comment = Comment.new :commentable => @document, :public => true

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @comment }
    end
  end

  # GET /comments/1/edit
  def edit
  #  @comment = Comment.find(params[:id])

  end

  # POST /comments
  # POST /comments.xml
  def create
    @comment = Comment.new(params[:comment])
    @comment.user = current_user
    respond_to do |format|
      if @comment.save
        format.html { redirect_to( catalog_comment_url(:catalog_id => @comment.commentable_id, :id => @comment.id, :no_layout => (1 if request.xhr?))) }
        format.xml  { render :xml => @comment, :status => :created, :location => @comment }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /comments/1
  # PUT /comments/1.xml
  def update
  #  @comment = Comment.find(params[:id])

    respond_to do |format|
      if @comment.update_attributes(params[:comment])
        format.html { redirect_to( catalog_comment_url(:catalog_id => @comment.commentable_id, :id => @comment.id, :no_layout => (1 if request.xhr?))) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.xml
  def destroy
  #  @comment = Comment.find(params[:id])
    @comment.destroy
    
    respond_to do |format|
      format.html { redirect_to( catalog_comments_url(:catalog_id => @comment.commentable_id,:no_layout => (1 if request.xhr?))) }
      format.xml  { head :ok }
    end
  end
end
