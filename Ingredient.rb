lambda {
  describes = []
  adds = []
  removes = []
  noms = []
  tastes = []

  Kernel.send :define_method :describe do |name, &block|
    describes[name] = block
  end

  Kernel.send :define_method :add do |name, &block|
    adds[name] = block
  end

  Kernel.send :define_method :remove do |name, &block|
    removes[name] = block
  end

  Kernel.send :define_method :nom do |name, &block|
    noms[name] = block
  end

  Kernel.send :define_method :taste do |name, &block|
    tastes[name] = block
  end
}.call

Dir.glob('*.ingredient').each do |file|
  load file
end
