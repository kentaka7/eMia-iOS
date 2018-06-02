platform :ios, '10.0'
use_frameworks!

target 'eMia' do
    pod 'Firebase/Core'
    pod 'Firebase/Database'
    pod 'Firebase/Storage'
    pod 'Firebase/Auth'
    pod 'Firebase/RemoteConfig'
    pod 'Firebase/Messaging'

    pod 'RxSwift'
    pod 'RxCocoa'
    pod 'RxDataSources'
    pod 'RealmSwift'
    pod 'RxRealm'

    pod 'IQKeyboardManagerSwift'
    pod 'SwiftyJSON'
    pod 'NextGrowingTextView'
    pod 'NVActivityIndicatorView'
    
    pod 'SwiftyNotifications', '~>0.2'
    pod 'Then', '2.1.0'
    pod 'Reachability'
    
    pod 'AwesomeCache'
    
end

# enable tracing resources
# to check do anywhere
# print("resources: \(RxSwift.Resources.total)")

post_install do |installer|
    installer.pods_project.targets.each do |target|
        if target.name == 'RxSwift'
            target.build_configurations.each do |config|
                if config.name == 'Debug'
                    config.build_settings['OTHER_SWIFT_FLAGS'] ||= ['-D',
                    'TRACE_RESOURCES']
                end
            end
        end
    end
    # The workaround starts here !!!!!
    Dir.glob(installer.sandbox.target_support_files_root + "Pods-*/*.sh").each do |script|
        flag_name = File.basename(script, ".sh") + "-Installation-Flag"
        folder = "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
        file = File.join(folder, flag_name)
        content = File.read(script)
        content.gsub!(/set -e/, "set -e\nKG_FILE=\"#{file}\"\nif [ -f \"$KG_FILE\" ]; then exit 0; fi\nmkdir -p \"#{folder}\"\ntouch \"$KG_FILE\"")
        File.write(script, content)
    end
end
