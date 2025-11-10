require 'fileutils'

def flutter_application_path
  File.expand_path(File.join(__dir__, '..', 'ios'))
end

def generated_xcode_build_settings_path
  File.join(flutter_application_path, 'Flutter', 'Generated.xcconfig')
end

def flutter_root
  path = generated_xcode_build_settings_path
  unless File.exist?(path)
    raise "#{path} must exist. Run `flutter pub get` before calling pod install."
  end

  File.foreach(path) do |line|
    match = line.match(/FLUTTER_ROOT=(.*)/)
    return match[1].strip if match
  end
  raise 'FLUTTER_ROOT not set in Generated.xcconfig.'
end

def flutter_podhelper
  File.expand_path(File.join(flutter_root, 'packages', 'flutter_tools', 'bin', 'podhelper.rb'))
end

def ensure_flutter_podhelper
  require flutter_podhelper unless defined?(Flutter::PodHelper)
end

def flutter_ios_podfile_setup
  ensure_flutter_podhelper
  Flutter::PodHelper.setup_podfile(File.expand_path('ios', __dir__))
end

def flutter_install_all_ios_pods(relative_application_path)
  ensure_flutter_podhelper
  Flutter::PodHelper.install_all_ios_pods(File.expand_path(relative_application_path, __dir__))
end

def flutter_install_ios_engine_pod
  ensure_flutter_podhelper
  Flutter::PodHelper.install_ios_engine_pod
end

def flutter_install_ios_plugin_pods(relative_application_path)
  ensure_flutter_podhelper
  Flutter::PodHelper.install_plugin_pods(File.expand_path(relative_application_path, __dir__))
end
