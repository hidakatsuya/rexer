theme :theme_a, git: {url: "/git-server-repos/theme_a.git"}

env :env1 do
  plugin :plugin_a, git: {url: "/git-server-repos/plugin_a.git", tag: ENV["PLUGIN_A_LATEST_VERSION"]}
end

env :env2 do
  theme :theme_a, git: {url: "/git-server-repos/theme_a.git", branch: "master"}
  plugin :plugin_a, git: {url: "/git-server-repos/plugin_a.git", branch: "master"}
end

env :env3 do
  plugin :plugin_a, git: {url: "/git-server-repos/plugin_a.git", branch: "stable"} do
    installed do
      puts ERB.new("<%= 'plugin_a installed' %>").result
    end

    uninstalled do
      puts "plugin_a uninstalled"
    end
  end

  theme :theme_a, git: {url: "/git-server-repos/theme_a.git"} do
    installed do
      puts "theme_a installed"
    end

    uninstalled do
      puts "theme_a uninstalled"
    end
  end
end

env :default, :env4 do
  plugin :plugin_a, git: {url: "/git-server-repos/plugin_a.git"}
end
