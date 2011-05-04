module SearchHelper

  # XXX 
  def top_level_categories
    response = Blacklight.solr.find :rows => 0, :'facet.field' => 'merlot_s', :'f.merlot_s.facet.prefix' => '1/', 'f.merlot_s.facet.sort' => 'index'
    response.facet_by_field_name('merlot_s')
  end

  def collections_list
    response = Blacklight.solr.find :fq => ['dc_type_s:Collection'], 'fl' => 'id,title_display', 'sort' => 'title_sort asc' 
    response.docs.map { |x| SolrDocument.new(x) }
  end
end
