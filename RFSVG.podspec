Pod::Spec.new do |s|
  s.name             = "RFSVG"
  s.version          = "1.0.0"
  s.license          = "MIT"
  s.summary          = "A SVG caching library."
  s.description      = <<-DESC
                       Maintains a cache of rasterized SVG images to minimize the need to re-parse and re-render the SVG file every time it needs to be displayed.
                       DESC
  s.homepage         = "https://github.com/raumfeld/RFSVG"
  s.author           = { "Dunja Lalic" => "dunja.lalic@teufel.de" }
  s.source           = { :git => "https://github.com/raumfeld/RFSVG.git", :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.requires_arc = true
  
  s.source_files = ['RFSVG/**/*.{h,m,swift}']

  s.dependency 'PocketSVG'
  
end
