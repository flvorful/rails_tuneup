module RailsTuneup
  module Environment

    def environment
      {
        'application_name' => application_name,
        'rails_env' => rails_env,
        'rails_version' => rails_version
      }
    end

    def rails_env
      Rails.env || 'development'
    end

    def rails_version
      RailsTuneup::Version.rails.to_s
    end

    def application_name
      app_name = Rails.root.split('/').last
      return app_name unless app_name == 'current'
      Rails.root.join('..').split('/').last
    end

  end
end
