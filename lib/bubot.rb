require "bubot/version"

module Bubot

  def watch(method_name, timeout, &block)
    define_method("#{method_name}_with_feature") do
      start_time = Time.now
      response = send("#{method_name}_without_feature".to_sym)
      if (total_time = Time.now - start_time) > timeout
        block.call(self, total_time)
      end
      response
    end

    alias_method_chain_or_register(method_name)
  end

  private

  def alias_method_chain_or_register(method_name)
    if method_defined?(method_name)
      alias_method_chain(method_name)
    else
      (@method_names ||= []).push(method_name)
    end
  end

  def method_added(method_name)
    if (@method_names ||= []).delete(method_name)
      alias_method_chain(method_name)
    end
  end

  def alias_method_chain(method_name)
    alias_method "#{method_name}_without_feature".to_sym, method_name
    alias_method  method_name, "#{method_name}_with_feature".to_sym
  end

end
