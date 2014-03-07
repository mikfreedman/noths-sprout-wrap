include_recipe "sprout-osx-base::homebrew"
include_recipe "noths::ruby"

brew "thoughtbot/formulae" do
  action :tap
end

brew "gitsh"

