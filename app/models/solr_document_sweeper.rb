class SolrDocumentSweeper < ActionController::Caching::Sweeper
  observe SolrDocument

  def after_save(document)
    expire_action :controller => 'catalog', :action => 'show', :id => document.id
  end
end
