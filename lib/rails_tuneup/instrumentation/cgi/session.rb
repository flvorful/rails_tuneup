module Fiveruns
  module Tuneup
    module Instrumentation
      module CGI
        module Session
          def self.included(base)
            RailsTuneup.instrument base, InstanceMethods
          end
          module InstanceMethods
            def initialize_with_fiveruns_tuneup(*args, &block)
              RailsTuneup.step "Create session", :model do
                initialize_without_fiveruns_tuneup(*args, &block)
              end
            end
            def close_with_fiveruns_tuneup(*args, &block)
              RailsTuneup.step "Close session", :model do
                close_without_fiveruns_tuneup(*args, &block)
              end
            end
            def delete_with_fiveruns_tuneup(*args, &block)
              RailsTuneup.step "Delete session", :model do
                delete_without_fiveruns_tuneup(*args, &block)
              end
            end
          end
        end
      end
    end
  end
end