Pod::Spec.new do |s|
  s.name             = "DDDKeychainWrapper"
  s.version          = "1.0.0"
  s.summary          = "DDDKeychainWrapper offers a simple access to store and retrive your sensitive data from the Keychain."
  s.homepage         = "https://github.com/axldyb/DDDKeychainWrapper"
  s.license          = 'MIT'
  s.author           = { "axldyb" => "aksel.dybdal@shortcut.no" }
  s.source           = { :git => "https://github.com/axldyb/DDDKeychainWrapper.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/axldyb'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'

  s.frameworks = 'Security'
end
