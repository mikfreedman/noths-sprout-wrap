git "checkout notonthehighstreet" do
  destination File.expand_path("~/workspace/notonthehighstreet")
  repository  "git@github.com:notonthehighstreet/noths-sprout-wrap.git"
  revision    "integration"
  action      :checkout
end