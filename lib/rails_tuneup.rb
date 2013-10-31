require 'rails'
require 'active_support/core_ext/numeric/time'
require 'active_support/dependencies'

require "rails_tuneup/engine"

module RailsTuneup
  autoload :Urls, "rails_tuneup/urls"
  autoload :AssetTags, "rails_tuneup/asset_tags"
  autoload :Runs, "rails_tuneup/runs"
  autoload :Utilities, "rails_tuneup/instrumentation/utilities"
  autoload :Environment, "rails_tuneup/environment"
  autoload :Schema, "rails_tuneup/schema"


  class << self


    attr_writer :collecting
    attr_accessor :running
    attr_reader :trend

    def logger
      @logger ||= returning Logger.new(log_file) do |l|
        RAILS_DEFAULT_LOGGER.info(log_format % "Logging in #{log_file}")
        l.level = Logger::INFO
      end
    end

    def run(controller, request)
      @running = (!controller.is_a?(TuneupController) && !request.xhr?)
      result = nil
      record controller, request do
        result = yield
      end
      @running = false
      result
    end

    def config(&block)
      yield configuration
    end

    def configuration
      @configuration ||= ::RailsTuneup::Configuration.new
    end

    def collecting
      if defined?(@collecting)
        @collecting
      else
        @collecting = true
      end
    end

    def record(controller, request)
      if recording?
        @stack = [RailsTuneup::RootStep.new]
        @trend = nil
        @environment = environment
        yield
        log :info, "Persisting for #{request.url} using stub #{stub(request.url)}"
        data = @stack.shift
        persist(generate_run_id(request.url, data.time), @environment, schemas, data)
      elsif !@running
        # Plugin displaying the data
        # TODO: Support targeted selection (for historical run)
        if request.parameters['uri']
          last_id = last_run_id_for(request.parameters['uri'])
          log :info, "Retrieved last run id of #{last_id} for #{request.parameters['uri']} using stub #{stub(request.parameters['uri'])}"
          if last_id && (data = retrieve_run(last_id))
            @stack = [data]
            @trend = trend_for(last_id)
          else
            log :debug, "No stack found"
            clear_stack
          end
        else
          clear_stack
        end
        yield
      else
        yield
      end
      clear_stack
    end

    def recording?
      @running && @collecting
    end

    def start
      if supports_rails?
        load_configuration_file
        if configuration.instrument?
          yield
          install_instrumentation
          log :debug, "Using collector at #{collector_url}"
          log :debug, "Using frontend at #{frontend_url}"
          log :info, "Started."
        else
          log :warn, "Not configured to run in #{RAILS_ENV} environment, aborting."
        end
      end
    end

    def log(level, text)
      message = log_format % text
      logger.send(level, message)
      STDERR.puts message if level == :error
    end

    #######
    private
    #######

    def log_file
      File.join(configuration.log_directory, "tuneup.log")
    end

    def log_format
      " RailsTuneup (v#{RailsTuneup::Version::STRING}): %s"
    end

    def configuration_file
      File.join(RAILS_ROOT, 'config/tuneup.rb')
    end

    def load_configuration_file
      if File.exists?(configuration_file)
        require configuration_file
      end
    end

    def supports_rails?
      version = Rails::VERSION rescue nil
      return true unless version
      if version::MAJOR < 3
        log :error, "Sorry, RailsTuneup does not currently support Rails < 3.2; aborting load."
        false
      else
        log :info, "Rails version #{version::STRING} is supported, loading..."
        true
      end
    end

    def clear_stack
      @stack = nil
      @exclusion_stack = nil
    end

  end


end
