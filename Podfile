platform :ios, '8.1'


pod 'mailcore2-ios'
pod 'GTMOAuth2', git: 'https://github.com/google/gtm-oauth2.git', commit: '3494d6aa296412632c648ba00f0dd1006fef91fe'

use_frameworks!
pod 'KeychainSwift', '~> 3.0'

post_install do |installer|  
    installer.pods_project.build_configuration_list.build_configurations.each do |configuration|  
        configuration.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'  
    end  
end
