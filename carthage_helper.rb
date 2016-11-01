require 'xcodeproj'
require 'digest/sha1'

if ARGV.length < 1
   abort("❌:usage ruby carthage_helper.rb path/to/*.xcodeproj except/target(optional)")
end
if ARGV[0] == "help"
  abort("make sure Carthage📁 and *.xcodeproj in the same folder，or Carthage Helper not gonna work correctly")
end
Dir.chdir "#{ARGV[0]}"
$except_target = "#{ARGV[1]}"

if Dir["*.xcodeproj"].length == 0
   abort("❌:not found *.xcodeproj in path:#{ARGV[0]}")
end
$project_path = Dir["*.xcodeproj"][0]
$builded_frameworks = Dir["Carthage/Build/iOS/*.framework"]
$has_framworks = $builded_frameworks.length > 0

$project = Xcodeproj::Project.open($project_path)

user_name = ENV['USER']

dir = "/Users/#{user_name}/Library/Application\ Support/CarthageHelper"
if Dir.exists?(dir) == false
  Dir.mkdir(dir, 0700)
end
hash = Digest::SHA1.hexdigest($project_path)
carthage_frameworks = [dir, "/", hash, "_carthage_frameworks.txt"].join('')

$old_frameworks = Array.new
if File.exists?(carthage_frameworks) == true
  f = File.open(carthage_frameworks, "r")
  f.each_line do |line|
    raw = line.gsub! '[', ''
    raw = raw.gsub! ']', ''
    raw = raw.gsub! '"', ''
    rawNext = raw.gsub! ' ', ''
    if rawNext != nil
      raw = rawNext
    else
      rawNext = raw.gsub! "\n", ""
      if rawNext != nil
        raw = rawNext
      end
    end

    $old_frameworks = raw.split(",")
  end
  f.close
end
File.open(carthage_frameworks, "w+") do |f|
  f.puts("#{$builded_frameworks}")
end

$to_delete_frameworks = Array.new
$old_frameworks.each do |old|
  if $builded_frameworks.include?(old) == false
    $to_delete_frameworks.push(old)
  end
end


$project.targets.each do |target|

   target_name = target.name
   if target_name == $except_target
     next
   end


   need_add_copy_script = false
   need_copy_file_action = false


   info_plist = target.common_resolved_build_setting("INFOPLIST_FILE")#"#{target_name}/Info.plist"
   plist = Xcodeproj::Plist.read_from_path(info_plist)
   osType = plist["CFBundlePackageType"]


   schemeFolder = Xcodeproj::XCScheme.user_data_dir($project_path)
   schemePath = "#{target_name}.xcscheme"
   pp = [Dir.pwd, "/", schemeFolder, "/", schemePath].join('')

   if osType == "APPL"  # disable system log
      if File.exists?(pp) == false
         schemeFolder = Xcodeproj::XCScheme.shared_data_dir($project_path)
         pp = [Dir.pwd, "/", schemeFolder, "/", schemePath].join('')
      end
      scheme = Xcodeproj::XCScheme.new(pp)

      param        = {}
      param[:key]  = "OS_ACTIVITY_MODE"
      param[:value] = "Disable"
      disableLog = Xcodeproj::XCScheme::EnvironmentVariable.new(param)
      if scheme.launch_action.environment_variables.class == NilClass
         scheme.launch_action.environment_variables = Hash.new
      end
      scheme.launch_action.environment_variables.assign_variable(disableLog)
      scheme.save!
      need_add_copy_script = $has_framworks
   elsif osType == "FMWK"  # shared framework
     if File.exists?(pp) == true
        Xcodeproj::XCScheme.share_scheme($project_path, target_name)
     end
   elsif osType == "BNDL"
      need_copy_file_action = $has_framworks
   end

   # add framework to linked frameworks
   input_paths = Array.new
   $builded_frameworks.each do |toAdd|
     input_paths.push("$(SRCROOT)/#{toAdd}")
     addOnce = false
     $project.frameworks_group.children.each do |child|

       if child.path != toAdd
         next
       end

       addRef = false
       target.frameworks_build_phases.files.each do |old|
         if old.file_ref.path == toAdd
           addOnce = true
           addRef = true
           break
         end
       end

       if addRef == false
         build = target.frameworks_build_phases.add_file_reference(child, true)
         addOnce = true
       end

       break
     end
     if addOnce == false
       file = $project.frameworks_group.new_reference(toAdd)
       build = target.frameworks_build_phases.add_file_reference(file, true)
     end
   end

   $to_delete_frameworks.each do |file|
     $project.frameworks_group.children.each do |child|
       if child.path == file
         target.frameworks_build_phases.remove_file_reference(child)
         puts "delete #{child}"
       end
     end
   end
   target.frameworks_build_phases.sort

   # add path for search

   $project.build_configurations.each do |conf|

      configuration = target.add_build_configuration('Debug', :debug)
      if conf.name == "Release"
         configuration = target.add_build_configuration('Release', :release)
      end
      settings = configuration.build_settings

      run_paths = settings['LD_RUNPATH_SEARCH_PATHS']
      run_path_class = run_paths.class
      if run_path_class == String
        new_array = run_paths.split(" ")
        run_paths = new_array
      elsif run_path_class == NilClass
        run_paths = Array.new
      end

      run_paths_to_add = ["@loader_path/Frameworks"]
      run_paths_to_add.each do |path|
        if run_paths.include?(path) == false
          run_paths.push(path)
        end
      end
      settings['LD_RUNPATH_SEARCH_PATHS'] = run_paths


      search_paths = settings['FRAMEWORK_SEARCH_PATHS']
      path_class = search_paths.class
      if path_class == String
        new_array = Array.new
        new_array.push(search_paths)
        search_paths = new_array
      elsif path_class == NilClass
        search_paths = Array.new
      end
      search_paths_to_add = ['$(inherited)', '$(PROJECT_DIR)/Carthage/Build/iOS']
      search_paths_to_add.each do |path|
        if search_paths.include?(path) == false
          search_paths.push(path)
        end
      end
      settings['FRAMEWORK_SEARCH_PATHS'] = search_paths

      #自动降级到 9.0
      conf.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = "9.0"
   end

   # add carthage copy script
   scriptName = "🤖Carthage"
   if target.shell_script_build_phases.length > 0
      target.shell_script_build_phases.each do |script|
         if script.name == scriptName
            # puts script.remove_from_project
            break
         end
      end
   end

   if need_add_copy_script == true
      newScript = target.new_shell_script_build_phase(scriptName)
      newScript.shell_path = "/bin/sh"
      newScript.shell_script = "/usr/local/bin/carthage copy-frameworks"
      newScript.input_paths = input_paths
   end

# unitext
   actionName = "Copy Carthage frameworks"
   if target.copy_files_build_phases.length > 0
      target.copy_files_build_phases.each do |script|
         if script.name == actionName
            script.remove_from_project
            break
         end
      end
   end

   if need_copy_file_action == true
      action = target.new_copy_files_build_phase(actionName)
      action.symbol_dst_subfolder_spec=(:frameworks)
      $builded_frameworks.each do |toAdd|

        $project.frameworks_group.children.each do |child|
          if child.path == toAdd
            build = action.add_file_reference(child, true)
            if build.settings.class == NilClass
               build.settings = { 'ATTRIBUTES' => ['CodeSignOnCopy'] }
            end#if
          end#if
        end#$project

      end
      action.sort
   end
end
$project.save
puts "🍻: carthage helper done"
