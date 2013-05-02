module MaglevSupport
  def self.to_str
    to_s
  end

  # Copied from activesupport/lib/active_support/inflector/methods.rb
  def self.constantize(camel_cased_word)
    names = camel_cased_word.split('::')
    names.shift if names.empty? || names.first.empty?

    constant = Object
    names.each do |name|
      constant = constant.const_defined?(name) ? constant.const_get(name) : constant.const_missing(name)
    end
    constant
  end
end

require "maglev_record/maglev_support/active_support_patch"
