include_recipe "sprout-osx-apps::sublime_text"

application_support = File.expand_path("~/Library/Application Support/Sublime Text 2/Packages/User")

remote_file "sublime filename_to_clipboard" do
  source "https://raw.github.com/dougdroper/filename_to_clipboard/master/filename_to_clipboard_command.py"
  path   File.join(application_support, "filename_to_clipboard_command.py")
end

template "sublime_text key mappings" do
  source "sublime_text/Default (OSX).sublime-keymap"
  path   File.join(application_support, "Default (OSX).sublime-keymap")
end