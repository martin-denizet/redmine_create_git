# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

RedmineApp::Application.routes.draw do

  match 'create_git/:project_id', :controller => 'create_git', :action => 'new', :via => [:get]
  match 'create_git/:project_id', :controller => 'create_git', :action => 'create', :via => [:post]
end