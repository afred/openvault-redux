ActionController::Routing::Routes.draw do |map|
  # Login, Logout, UserSessions
  map.resources :user_sessions, :protocol => ((defined?(SSL_ENABLED) and SSL_ENABLED) ? 'https' : 'http')
  map.login "login", :controller => "user_sessions", :action => "new"
  map.logout "logout", :controller => "user_sessions", :action => "destroy"

  # Set the default controller:
  map.root :controller => 'catalog', :action=>'index'
  map.resources :bookmarks, :collection => {:clear => :delete}
  map.resource :user

  map.catalog_facet "catalog/facet/:id", :controller=>'catalog', :action=>'facet'

  map.resources :search_history, :collection => {:clear => :delete}
  map.resources :saved_searches, :collection => {:clear => :delete}, :member => {:save => :put}

  map.resources(:catalog,
    :only => [:index, :show, :update],
    # /catalog/:id/image <- for ajax cover requests
    # /catalog/:id/status
    # /catalog/:id/availability
    :member=>{:image=>:get, :embed => :get, :status=>:get, :availability=>:get, :librarian_view=>:get},
    # /catalog/map
    :collection => {:map => :get, :opensearch=>:get, :citation=>:get, :email=>:get, :sms=>:get, :endnote=>:get, :send_email_record=>:post},
      :requirements => { :id => /([A-Za-z0-9]|:|-|\.)+/ }
  )
    

  map.feedback 'feedback', :controller=>'feedback', :action=>'show'
  map.feedback_complete 'feedback/complete', :controller=>'feedback', :action=>'complete'
    
  map.resources :folder, :only => [:index, :update, :destroy], :collection => {:clear => :delete }

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
