module OAI::Provider::Metadata
  class PBCore < Format
    def initialize
      @prefix = 'pbcore'
      @schema = ''
      @namespace = ''
      @element_namespace = 'pbcore'
      @fields = []
    end
    def header_specification
      {}
    end
  end
end
BlacklightOaiProvider::SolrDocumentProvider.register_format OAI::Provider::Metadata::PBCore.instance
