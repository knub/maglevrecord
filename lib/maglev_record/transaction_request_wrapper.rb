gem 'actionpack'
require 'action_pack'
require 'abstract_controller'

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

