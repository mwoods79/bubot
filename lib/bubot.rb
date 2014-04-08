require "bubot/version"

module Bubot

  def self.included(base)
    base.extend ClassMethods
    interceptor = const_set "#{base.name}Interceptor", Module.new
    base.prepend interceptor
  end

  module ClassMethods
    def watch(method_name, timeout: 0, with: nil, &block)
      interceptor = const_get "#{self.name}Interceptor"
      interceptor.module_eval do
        past_time_block = with || (block if block_given?)

        define_method(method_name) do |*args, &block|
          start_time = Time.now

          method_return_value = super(*args, &block)

          if (total_time = Time.now - start_time) >= timeout
            past_time_block.call(self, total_time, method_return_value)
          end

          method_return_value
        end
      end
    end
  end
end
