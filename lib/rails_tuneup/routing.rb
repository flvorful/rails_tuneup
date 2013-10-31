module RailsTuneup
  module Routing

    def self.install
      ActionController::Routing::RouteSet.send(:include, self)
    end

    def self.included(base)
      base.alias_method_chain :draw, :rails_tuneup
    end

    def draw_with_rails_tuneup(*args, &block)
      draw_without_rails_tuneup(*args) do |map|
        map.connect '/tuneup', :controller => 'rails_tuneup/tuneup', :action => 'show'
        map.connect '/tuneup/:action', :controller => 'rails_tuneup/tuneup'
        yield map
      end
    end
  end
end


