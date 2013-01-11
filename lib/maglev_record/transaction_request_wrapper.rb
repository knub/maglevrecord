gem 'actionpack'
require 'action_pack'
require 'abstract_controller'

module MaglevRecord
  class TransactionRequestWrapper
    @@wrapper_installed = false
    
    def self.is_wrapper_installed
      @@wrapper_installed
    end

    def self.install_request_wrapper
      if !@@wrapper_installed
        begin
          # We wrap process because process_action might be overridden in a subclass.
          AbstractController::Base.alias_method :process_proceed, :process
          AbstractController::Base.remove_method :process
          AbstractController::Base.class_eval <<-PROCESS
            def process(action, *args)
              Maglev.abort_transaction
              process_proceed(action, *args)
              Maglev.commit_transaction
            end
          PROCESS
          
          @@wrapper_installed = true
        rescue Exception
          # For some reason installing the wrapper failed
        end
      end
    end

  end
end

MaglevRecord::TransactionRequestWrapper.install_request_wrapper

