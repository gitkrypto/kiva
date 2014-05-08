require 'fileutils'

module NXT
  class Runner
    
    def initialize(id)
      @lock_file = File.join(ENV['HOME'], "worker_lock_#{id}") 
    end
    
    def perform
      unless File.exists? @lock_file
        begin
          FileUtils.touch @lock_file
          begin      
            yield     
          rescue Exception => exception
            logger.fatal(
              "\n\n#{exception.class} (#{exception.message}):\n    " +
              clean_backtrace(exception).join("\n    ") +
              "\n\n"
            )
            raise exception
          end
        ensure
          File.delete @lock_file
        end
      end      
    end
    
    def clean_backtrace(exception)
      if backtrace = exception.backtrace
        if defined?(RAILS_ROOT)
          backtrace.map { |line| line.sub RAILS_ROOT, '' }
        else
          backtrace
        end
      end
    end
    
    def logger
      Rails.logger
    end    
  end
end