module ActiveSupport
  class << Deprecation
    # Declare that a method has been deprecated.
    def deprecate_methods(target_module, *method_names)
      options = method_names.extract_options!
      method_names += options.keys
      method_names.each do |method_name|
        next unless method_name.respond_to?(:to_sym)  # next if Fixnum
        next if method_name == :none                  # check from rubygems/deprecate.rb
        next if method_name.to_s.include?(".")             # . in method names is not allowed
        # workaround for :==
        if method_name.to_sym == :==
          method_name = "equal?"
        end
        target_module.alias_method_chain(method_name, :deprecation) do |target, punctuation|
          target_module.module_eval(<<-end_eval, __FILE__, __LINE__ + 1)
            def #{target}_with_deprecation#{punctuation}(*args, &block)
              ::ActiveSupport::Deprecation.warn(
                ::ActiveSupport::Deprecation.deprecated_method_warning(
                  :#{method_name},
                  #{options[method_name].inspect}),
                caller
              )
              send(:#{target}_without_deprecation#{punctuation}, *args, &block)
            end
          end_eval
        end
      end
    end
  end
end
