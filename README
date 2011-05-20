# Open Vault

WGBH Open Vault is a Ruby on Rails 3.0 application that uses [Blacklight](http://projectblacklight.org) to provide a media-centric digital library application. Blacklight uses the [Apache SOLR](http://lucene.apache.org/solr) search engine to index and search full text and/or metadata. Open Vault also uses [Fedora](http://fedora-commons.org) to store and manage content, metadata, and object relationships.

This core is not intended to be an out-of-the-box solution and may take additional work to deploy in other contexts. We would highly recommend looking at Blacklight <http://projectblacklight.org> or Hydra <https://wiki.duraspace.org/display/hydra/The+Hydra+Project> as a starting place for similar functionality, supported by a robust community.

A significant portion of the work and innovation that went into the making of WGBH Open Vault <http://openvault.wgbh.org> has been released as modular Blacklight plugins, simple demonstrators, or contributed back to core projects (such as Blacklight), making it easier for the community to build similar projects. 

Blacklight OAI provider:
https://github.com/cbeer/blacklight_oai_provider

Blacklight oEmbed provider:
https://github.com/cbeer/blacklight_oembed

Blacklight unAPI provider:
https://github.com/cbeer/blacklight_unapi

Blacklight User Generated Content:
https://github.com/cbeer/blacklight_user_generated_content

Blacklight plugin exposing Solr More-Like-This functionality:
https://github.com/cbeer/blacklight_mlt

Blacklight plugin exposing Solr Highlighting functionality:
https://github.com/cbeer/blacklight_highlight_plugin.git

Core Fedora content models used by WGBH Open Vault:
https://github.com/cbeer/fedora-content-models

Demonstrator of synchronized media and text:
https://github.com/cbeer/ave

Demonstrator for manually aligning formatted text with media:
https://github.com/cbeer/ave-sync

Ruby implementation of An Open Digital Rights Language-based Policy Decision Point:
https://github.com/cbeer/ruby-odrl


## Dependencies

* ruby v1.8.7 or higher
* git
* java 1.5 or higher
* ImageMagick (for scaling thumbnails)
* Fedora Commons repository (with the resource index enabled)
* Apache Solr (version 3.1+ recommended)
* Optionally, Wordpress for managing utility and "blog" content.

In addition, you must have the Bundler and Rails 3.0 gems installed. Other gem dependencies are defined in the blacklight.gemspec file and will be automatically loaded by Bundler.

## Installation instructions

```
# install Rails 3, bundler, and system dependencies
$ git clone git@github.com:WGBH/openvault-redux.git
$ cd openvault-redux
$ bundle install
# configure files in ./config, especially ./config/solr.yml, ./config/fedora.yml, and ./config/initializers/blacklight.rb
$ git clone https://github.com/projecthydra/hydra-jetty.git
# configure fedora and hydra
[...]
$ rails s
```
