Pod::Spec.new do |s|
    s.name         = 'swiftScan'
    s.version      = '1.1.3'
    s.summary      = 'ios swift scan wrapper'
    s.homepage     = 'https://github.com/MxABC/swiftScan'
    s.license      = 'MIT'
    s.authors      = {'MxABC' => 'lbxia20091227@foxmail.com'}
    s.platform     = :ios, '8.0'
    s.source       = {:git => 'https://github.com/MxABC/swiftScan.git', :tag => s.version}
    s.ios.deployment_target = "8.0"
    s.source_files = 'Source/*.swift'
end
