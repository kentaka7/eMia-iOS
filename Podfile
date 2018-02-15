platform :ios, '10.0'
use_frameworks!

target 'eMia' do
   
   pod 'Firebase/Core'
   pod 'Firebase/Database'
   pod 'Firebase/Storage'
   pod 'Firebase/Auth'
   pod 'Firebase/RemoteConfig'
   pod 'Firebase/Messaging'
   
   pod 'IQKeyboardManagerSwift'
   pod 'DTCollectionViewManager', '~> 6.0'
   pod 'AwesomeCache', '~> 3'
   
   pod 'SwiftyJSON'
   pod 'SwiftyNotifications', '~>0.2'
   pod 'ReachabilitySwift', '~> 3'
   
   pod 'NextGrowingTextView'
   
   pod 'NVActivityIndicatorView'

end

# The workaround starts here !!!!!

post_install do |installer|
   Dir.glob(installer.sandbox.target_support_files_root + "Pods-*/*.sh").each do |script|
      flag_name = File.basename(script, ".sh") + "-Installation-Flag"
      folder = "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
      file = File.join(folder, flag_name)
      content = File.read(script)
      content.gsub!(/set -e/, "set -e\nKG_FILE=\"#{file}\"\nif [ -f \"$KG_FILE\" ]; then exit 0; fi\nmkdir -p \"#{folder}\"\ntouch \"$KG_FILE\"")
      File.write(script, content)
   end
end
