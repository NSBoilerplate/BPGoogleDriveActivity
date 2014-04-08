Pod::Spec.new do |s|
  s.name             = "BPGoogleDriveActivity"
  s.version          = "0.0.2"
  s.summary          = "BPGoogleDriveActivity is an iOS UIActivity subclass for uploading to Google Drive."
  s.description      = <<-DESC
An iOS UIActivity subclass implementing uploads to Dropbox – Based on [GSDropboxActivity](https://github.com/goosoftware/GSDropboxActivity).
                       DESC
  s.homepage         = "https://github.com/NSBoilerplate/BPGoogleDriveActivity"
  s.license          = 'Creative Commons Attribution 3.0 Unported License'
  s.author           = { "jsambells" => "bp@tropicalpixels.com" }
  s.source           = { :git => "git@github.com:NSBoilerplate/BPGoogleDriveActivity.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/iamamused'

  s.platform     = :ios, '6.1'
  s.requires_arc = true

  s.source_files = 'Classes/**/*.{m,h}'
  s.public_header_files = 'Classes/**/*.h'

  s.resources = 'Assets/*.png'

  s.frameworks = 'Foundation', 'UIKit'
  s.dependency 'Google-API-Client', '~> 0.1'

end
