Pod::Spec.new do |spec|
    spec.name         = "MultipartFormDataParser"
    spec.version      = "2.2.0"
    spec.summary      = "Mocking UserDefaults for tests"
        
    spec.description  = <<-DESC
                        MultipartFormDataParser is a testing tool for `multipart/form-data` request in Swift.
                        This library provides a parser for `multipart/form-data` request to test it briefly.
                        DESC
    
    spec.homepage     = "https://github.com/417-72KI/#{spec.name}"
    spec.readme       = "https://github.com/417-72KI/#{spec.name}/blob/#{spec.version}/README.md"
    spec.license      = { :type => "MIT", :file => "LICENSE" }
    
    spec.author       = { "417.72KI" => "417.72ki@gmail.com" }
    spec.social_media_url   = "https://twitter.com/417_72ki"
    
    spec.osx.deployment_target  = "12.0"
    spec.ios.deployment_target  = "15.0"
    spec.tvos.deployment_target = "15.0"
    
    spec.requires_arc = true
        
    spec.source         = { :git => "https://github.com/417-72KI/#{spec.name}.git", :tag => "#{spec.version}" }
    spec.source_files   = 'Sources/MultipartFormDataParser/**/*.swift'
    spec.swift_versions = ['5.8', '5.9', '5.10']
    spec.frameworks     = 'Foundation'
end
