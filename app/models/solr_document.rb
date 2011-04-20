require_dependency( 'vendor/plugins/blacklight/app/models/solr_document.rb')

class SolrDocument
  def surrogate
    @surrogate ||= Surrogate.with_id get(:pid_s) 
  end

  def save
    surrogate.save!
    @surrogate = Surrogate.with_id get(:pid_s)
    Blacklight.solr.add fedora_object.to_solr, :add_attributes => { :commitWithin => 10 } rescue nil
    nil
  end
end
