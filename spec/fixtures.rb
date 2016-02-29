def fixture(name)
  File.read("./spec/fixtures/#{name}")
end

def fixture_path(name)
  "./spec/fixtures/#{name}"
end