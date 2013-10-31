RailsTuneup::Engine.routes.draw do
  match '/:action', :controller => 'tuneup'

  root :to => 'tuneup#show'
end
