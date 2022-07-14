

target 'mapmobilitydemo' do
  use_frameworks!
  
  pod 'Tencent-MapSDK', "4.5.6.1"
#  pod 'TencentMapMobilityBoardingPlacesSDK' #推荐上车点SDK
#  pod 'TencentMapMobilityNearbyCarsSDK' #周边车辆SDK
  pod 'SVProgressHUD'
end

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
  end
end
