Openvault::Application.routes.draw do
  devise_for :users

  match 'catalog/:id/tag', :to => 'catalog#tag', :as => 'tag_catalog'

  resources :comments

  match "catalog_ugc/facet/:id", :to => 'catalog_ugc#facet'
  match 'users/comments', :to => 'catalog_ugc#index', :as => "my_page"

  match "collections/facet/:id", :to => 'collections#facet'
  resources :collections, :only => [:index, :show]

  # Catalog stuff.
  match 'catalog/map', :as => "map_catalog"
  match 'catalog/opensearch', :as => "opensearch_catalog"
  match 'catalog/citation', :as => "citation_catalog"
  match 'catalog/email', :as => "email_catalog"
  match 'catalog/sms', :as => "sms_catalog"
  match 'catalog/endnote', :as => "endnote_catalog"
  match 'catalog/send_email_record', :as => "send_email_record_catalog"
  match "catalog/facet/:id", :to => 'catalog#facet', :as => 'catalog_facet'
  match 'catalog/unapi', :to => "catalog#unapi", :as => 'unapi'
  resources :catalog, :only => [:index, :show, :update], :constraints => { :id => /([A-Za-z0-9]|:|-|\.)+([A-Za-z0-9]|:|-){4}/ } do
    member do
      get 'cite'
    end
    resources :comments
    resource :tags
  end

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
