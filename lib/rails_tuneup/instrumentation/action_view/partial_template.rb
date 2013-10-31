module Fiveruns
  module Tuneup
    module Instrumentation
      module ActionView
        module PartialTemplate       
          
          def self.included(base)
            RailsTuneup.instrument base, InstanceMethods
          end
          
          def self.relevant?
            RailsTuneup::Version.rails < RailsTuneup::Version.new(2,1,0) ? false : true
          end
          
          module InstanceMethods

            def render_with_fiveruns_tuneup(*args, &block)
              RailsTuneup.step "Render partial #{path}", :view do
                render_without_fiveruns_tuneup(*args, &block)
              end
            end
            
          end
        end
      end
    end
  end
end