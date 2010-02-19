module Kernel

  #
  def object_set(options=nil)
    options.each do |k,v|
      __send__("#{k}=", v)
    end if options
    yield(self) if block_given?
  end

end

