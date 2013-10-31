module RailsTuneup::CustomMethods
  
  # Manually instrument methods
  def tuneup(*args)
    RailsTuneup.add_custom_methods(self, *args)
  end
  
end
