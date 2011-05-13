class DatasetsController < ApplicationController
  access_control do
    allow :admin
  end

  # GET /datasets
  # GET /datasets.xml
  def index
    @order = params[:order] || 'created_at desc'
    @datasets = Dataset.find(:all, :order => @order, :conditions => params[:conditions]) 
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @datasets }
      format.rss
    end
  end

  # GET /datasets/1
  # GET /datasets/1.xml
  def show
    @dataset = Dataset.find(params[:id])
    redirect_to catalog_url(:id => @dataset.pid) and return
  end

  # GET /datasets/new
  # GET /datasets/new.xml
  def new
    @dataset = Dataset.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @dataset }
    end
  end

  # GET /datasets/1/edit
  def edit
  end

  # POST /datasets
  # POST /datasets.xml
  def create
    @dataset = Dataset.new(params[:dataset])
    @dataset.user = current_user

    respond_to do |format|
      if @dataset.save
        @dataset.process!
        format.html { redirect_to(@dataset, :notice => 'Dataset was successfully created.') }
        format.xml  { render :xml => @dataset, :status => :created, :location => @dataset }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @dataset.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /datasets/1
  # PUT /datasets/1.xml
  def update
    respond_to do |format|
      if @dataset.update_attributes(params[:dataset])
        format.html { redirect_to(@dataset, :notice => 'Dataset was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @dataset.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /datasets/1
  # DELETE /datasets/1.xml
  def destroy
    @dataset.destroy

    respond_to do |format|
      format.html { redirect_to(datasets_url) }
      format.xml  { head :ok }
    end
  end
end
