Gem::Specification.new do |s|
  s.name               = "xmapper"
  s.version            = "0.1.0"
  
  s.authors = ["Silvio Henrique Ferreira"]
  s.date = %q{2011-12-28}
  s.description = %q{XML Mapper. Maps XML to objects and vice-versa. Uses a nice nested-block syntax to define hierarchy.}
  s.email = %q{shferreira@me.com}
  s.homepage = %q{http://github.com/shf/xmapper}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{XML Mapper. Maps XML to objects and vice-versa. Uses a nice nested-block syntax to define hierarchy.}

  s.files = Dir.glob('lib/*.rb')
  s.add_dependency(%q<nokogiri>, [">= 1"])
end
