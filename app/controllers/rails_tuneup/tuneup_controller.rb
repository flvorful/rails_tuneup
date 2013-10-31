require 'net/https'
require 'ostruct'
require 'open-uri'

module RailsTuneup
  class TuneupController < RailsTuneup::ApplicationController

    def self.request_forgery_protection_options
      ApplicationController.request_forgery_protection_options || {}
    rescue
      Hash.new
    end

    def show
      session['rails_tuneup_last_uri'] = params[:uri]
      Rails.logger.silence do

      end
    end

    def update
      @config.update(params[:config])
      @config.save!
      redirect_to :action => 'show'
    end

    def register
      render :update do |page|
        page << "$('tuneup-panel').hide();"
        page << %[new Insertion.Bottom('tuneup-content', "#{escape_javascript(render(:partial => 'tuneup/panel/register.html.erb'))}");]
      end
    end


    def signin
      if api_key = retrieve_api_key
        @config['api_key'] = api_key
        @config.save!
      end
      render :update do |page|
        if api_key
          page << "$('tuneup-save-link').replace('#{escape_javascript(link_to_upload)}');"
          page << redisplay_last_run(false)
        else
          page << tuneup_show_flash(:error,
          :header => "TuneUp encountered an error",
          :message => "Could not access your FiveRuns TuneUp account.")
        end
      end
    end

    def upload
      token = upload_run
      render :update do |page|
        if token
          link = link_to_function("here", tuneup_open_run(token))
          page << tuneup_show_flash(:notice,
          :header => 'Run Uploaded to TuneUp',
          :message => "View your run #{link}.")
        else
          page << tuneup_show_flash(:error,
          :header => "TuneUp encountered an error",
          :message => "Could not upload run to your FiveRuns TuneUp account.")
        end
      end
    end

    def asset
      filename = File.basename(params[:file])
      if filename =~ /css$/
        response.content_type = 'text/css'
      end
      send_file File.join(File.dirname(__FILE__) << "/../assets/#{filename}")
    end

    def on
      collect true
    end

    def off
      collect false
    end

    def sandbox

    end

    #######
    private
    #######

    def collect(state)
      RailsTuneup.collecting = state
      render :update do |page|
        page << %[$('tuneup-panel').update("#{escape_javascript(render(:partial => 'tuneup/panel/show.html.erb'))}")]
      end
    end

    def find_config
      @config = TuneupControllerConfig.new
    end

    #
    # HTTP
    #

    def upload_run
      safely do
        http = Net::HTTP.new(upload_uri.host, upload_uri.port)
        http.use_ssl = true if RailsTuneup.collector_url =~ /^https/
        resp = nil
        # TODO: Support targeted upload
        filename = RailsTuneup.last_filename_for_run_uri(params[:uri])
        RailsTuneup.log :debug, "Uploading #{filename} for URI #{params[:uri]}"
        File.open(filename, 'rb') do |file|
          multipart = RailsTuneup::Multipart.new(file, 'api_key' => @config['api_key'] )
          # RailsTuneup.log :debug, multipart.to_s
          resp = http.post(upload_uri.request_uri, multipart.to_s, "Content-Type" => multipart.content_type)
        end
        case resp.code.to_i
        when 201
          return resp.body.strip rescue nil
        else
          RailsTuneup.log :error, "Received bad response from service (#{resp.inspect})"
          return false
        end
      end
    end

    def retrieve_api_key
      safely do
        http = Net::HTTP.new(api_key_uri.host, api_key_uri.port)
        http.use_ssl = true if RailsTuneup.collector_url =~ /^https/
        data = "email=#{CGI.escape(params[:email])}&password=#{CGI.escape(params[:password])}"
        resp = http.post(api_key_uri.path, data, "Content-Type" => "application/x-www-form-urlencoded")
        case resp.code.to_i
        when 200..299
          resp.body.strip rescue nil
        else
          RailsTuneup.log :error, "Received bad response from service (#{resp.inspect})"
          false
        end
      end
    end

    def safely
      yield
    rescue Exception => e
      RailsTuneup.log :error, "Could not access service: #{e.message}"
      false
    end

    def api_key_uri
      @api_key_uri ||= URI.parse("#{RailsTuneup.collector_url}/users")
    end

    def upload_uri
      @upload_uri ||= URI.parse("#{RailsTuneup.collector_url}/runs")
    end

  end
end