Gem::Specification.new do |s|
  s.name        = 'smbRpc'
  s.version     = '0.0.5'
  s.date        = '2019-02-09'
  s.summary     = "Interface to various Windows RPC services over SMB namepipes"
  s.description = "As describe in summary"
  s.authors     = ["Rungsree Singholka"]
  s.email       = 'rubysmbrpc@gmail.com'
  s.files       = `git ls-files -z`.split("\x0")
  s.required_ruby_version = '>= 2.2.0'
  s.add_runtime_dependency 'ruby_smb'
  s.add_runtime_dependency 'smbhash'
  s.homepage    =
    'https://github.com/smbRpc/smbRpc'
  s.license       = '0BSD'
end
