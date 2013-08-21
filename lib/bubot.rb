require "bubot/version"

module Bubot

  def watch(method_name, timeout, &block)
    define_method("#{method_name}_with_feature") do
      start_time = Time.now
      response = send("#{method_name}_without_feature".to_sym)
      if (Time.now - start_time) > timeout
        block.call(self)
      end
      response
    end

    if instance_methods.include?(method_name)
      alias_method_chain(method_name)
    else
      (@method_names ||= []).push(method_name)
    end
  end

  private

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
