# ProxyModule

a generic way to create modules that act as proxies to your existing Ruby modules

## Installation


```
gem install proxy_module
```

## Usage

```rb
require 'proxy_module'

module Tracing
  def self.prepend_features(base)
    mod = ProxyModule.for(base) do |_receiver, _method_name, args, block, super_method|
      puts _method_name
      super_method.call
    end
    base.prepend mod
  end
end

class Dog
  prepend Tracing

  def name
    "penny"
  end
end

Dog.new.name

# new
# name
#=> "penny"
```
