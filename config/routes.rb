Openvault::Application.routes.draw do
  ActiveAdmin.routes(self)
  Blacklight.add_routes(self, :except => [:catalog])

  root :to => 'catalog#home'

  devise_for :users

  match 'catalog/:id/tag', :to => 'catalog#tag', :as => 'tag_catalog'
  match 'blog' => 'blog#index', :as => 'blog'

  match 'user_generated_content/range_limit', :as => "range_limit_user_generated_content"
  match "users/page", :to => "user_generated_content#index", :as => "my_page"

  match "collections/facet/:id", :to => 'collections#facet'
  resources :collections, :only => [:index, :show]

  #match "catalog/org.wgbh.mla\:Vietnam" => redirect("/collections/vietnam-the-vietnam-collection")
  match "radio" => redirect("/catalog?f%5Bri_collection_ancestors_s%5D%5B%5D=info:fedora/org.wgbh.mla:pledge")
  match "user_util_links", :to => 'utility#user_util_links'

  match 'oai', :to => 'catalog#oai', :as => 'oai_provider'
  # Catalog stuff.
  match 'catalog/range_limit', :as => "range_limit_catalog"
  match 'catalog/map', :as => "map_catalog"
  match 'catalog/opensearch', :as => "opensearch_catalog"
  match 'catalog/citation', :as => "citation_catalog"
  match 'catalog/embed', :as => "embed_catalog"
  match 'catalog/oembed', :as => "oembed_catalog"
  match 'catalog/email', :as => "email_catalog"
  match 'catalog/sms', :as => "sms_catalog"
  match 'catalog/endnote', :as => "endnote_catalog"
  match 'catalog/send_email_record', :as => "send_email_record_catalog"
  match "catalog/facet/:id", :to => 'catalog#facet', :as => 'catalog_facet'
  match 'catalog/unapi', :to => "catalog#unapi", :as => 'unapi'
  resources :catalog, :only => [:index, :show, :update], :constraints => { :id => /([A-Za-z0-9]|:|-|\.)*([A-Za-z0-9]|:|-){7}/ } do
    member do
      get 'cite'
      get 'print'
      get 'image'
    end
    resources :comments, :constraints => { :id => /[0-9]+/ }
    resource :tags
  end

  resources :datasets 

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
