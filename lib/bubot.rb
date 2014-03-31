require "bubot/version"
require "active_support/concern"
require "active_support/callbacks"
require "active_support/core_ext/module/aliasing"

module Bubot
  extend ActiveSupport::Concern
  include ActiveSupport::Callbacks

  module ClassMethods
    def bubot(before_after_around, method_name, callback=nil, &block)
      configure_bubot method_name
      set_callback(method_name, before_after_around, (callback || block))
    end

    def watch(method_name, timeout: 0, with: nil, &block)
      configure_bubot method_name

      past_time_block = with || (block if block_given?)

      set_callback method_name, :around, ->(instance, &block) do
        start_time = Time.now

        method_return_value = block.call

        if (total_time = Time.now - start_time) >= timeout
          past_time_block.call(self, total_time, method_return_value)
        end
      end
    end

    private

    def configure_bubot(method_name)
      method_name_with_bubot = "#{method_name}_with_bubot".to_sym
      return if instance_methods.include? method_name_with_bubot

      define_callbacks method_name

      define_method(method_name_with_bubot) do |*args, &block|
        run_callbacks method_name do
          send("#{method_name}_without_bubot".to_sym, *args, &block)
        end
      end

      alias_method_chain_or_register_for_chaining method_name
    end

    def alias_method_chain_or_register_for_chaining(method_name)
      if method_defined?(method_name)
        alias_method_chain(method_name, :bubot)
      else
        (@method_names ||= []).push(method_name)
      end
    end

    def method_added(method_name)
      if (@method_names ||= []).delete(method_name)
        alias_method_chain(method_name, :bubot)
      end
    end
  end
end
