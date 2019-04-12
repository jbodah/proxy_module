require "proxy_module/version"

module ProxyModule
  def self.for(base, opts = {}, &handler)
    imod = __for(base, handler, opts)
    smod = __for(base.singleton_class, handler, opts)
    __add_method_added(base, imod, smod, handler, opts)

    Module.new do
      define_singleton_method :prepend_features do |base|
        base.prepend(imod)
        base.singleton_class.prepend(smod)
      end

      define_singleton_method :imod do
        imod
      end

      define_singleton_method :smod do
        smod
      end
    end
  end

  def self.__add_proxy_method(context, method_name, handler, opts)
    return if opts[:only] && !opts[:only].include?(method_name)
    return if opts[:except] && opts[:except].include?(method_name)

    context.class_eval do
      define_method method_name do |*args, &block|
        handler.call(self, method_name, args, block, proc { |args2, block2| super *args2, &block2 })
      end
    end
  end

  def self.__for(base, handler, opts)
    Module.new do
      base.instance_methods.each do |imethod|
        ProxyModule.__add_proxy_method(self, imethod, handler, opts)
      end
    end
  end

  def self.__add_method_added(_base, imod, smod, handler, opts)
    smod.module_eval do
      define_method :method_added do |imethod|
        return if imod.method_defined?(imethod) && imod.instance_method(imethod).owner == imod

        ProxyModule.__add_proxy_method(imod, imethod, handler, opts)

        super(imethod)
      end

      define_method :singleton_method_added do |smethod|
        return if smod.method_defined?(smethod) && smod.instance_method(smethod).owner == smod

        ProxyModule.__add_proxy_method(smod, smethod, handler, opts)

        super(smethod)
      end
    end
  end
end
