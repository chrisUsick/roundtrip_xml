Gem::Specification.new do |s|
  s.name        = 'roundtrip_xml'
  s.version     = '0.1.3'
  s.date        = '2016-03-17'
  s.summary     = "DSL which learns from XML"
  s.description = "A DSL that reads existing XML, generating an internal schema and using it to create a (somewhat) type safe DSL"
  s.authors     = ['Chris Usick']
  s.email       = 'chris.usick@northfieldit.com'
  s.files       = `git ls-files lib/ -z`.split("\x0")
  s.require_paths = ['lib']
  s.homepage    =
    'https://github.com/chrisUsick/roundtrip-xml'
  s.license       = 'MIT'

  s.add_dependency 'roxml', '~> 3.3'
  s.add_dependency 'nokogiri', '~> 1.6'
  s.add_dependency 'cleanroom', '~> 1.0'
  s.add_dependency 'nokogiri-diff', '~> 0.2'
end
