module RailsTuneup

  class Configuration

    attr_writer :log_directory
    def log_directory
      @log_directory ||= begin
        rails_log = Rails.logger.instance_eval { @log.path rescue @logdev.filename }
        File.dirname(rails_log)
      rescue
        Dir::tmpdir
      end
    end

    def environments
      @environments ||= %w(development)
    end

    def instrument?
      environments.map(&:to_s).include?(Rails.env)
    end

  end

end
