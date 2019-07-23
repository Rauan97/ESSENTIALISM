
platform :ios, '10.0'

def shared_pods
    pod 'JTAppleCalendar', '~> 7.1.6'
    pod 'SwiftLint'
    pod 'UIColor_Hex_Swift', '~> 4.0.2'
end

target 'Essentialism' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Active
  shared_pods

  target 'Essentialism-Dev' do
    shared_pods
  end

  target 'Essentialism-Stg' do
    shared_pods
  end

  target 'HabitReminderNotification' do
    shared_pods
  end

end
