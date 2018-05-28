Pod::Spec.new do |s|
  s.name         = "RNPredictIO"
  s.version      = "5.0.O"
  s.summary      = "A battery-optimized SDK for React Native to get real-time updates with context information when a user starts or ends a journey."
  s.description  = "PredictIO SDK for React Native"
  s.homepage     = "www.predict.io"
  s.license      = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
  s.author       = { "Kieran Graham" => "kieran@predict.io" }
  s.platform     = :ios, "8.0"
  # s.source       = { :git => "https://github.com/predict-io/react-native-predict-io.git", :tag => "master" }
  s.source       = { :git => "git@github.com:parktag/react-native-predictio-sdk.git", :tag => "develop" }

  s.source_files  = "ios/*.{h,m}"
  s.requires_arc = true

  s.dependency "React/Core"
  s.dependency "PredictIO", '~> 5.5.0'

  s.swift_version = '4.1'
end


