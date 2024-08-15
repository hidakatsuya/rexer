#!/bin/bash

case $1 in
    "add_readme_to_env3")
        cd /git-local-repos/plugin_a

        echo "update" > /git-local-repos/plugin_a/README
        git add README
        git commit -m "Add README"
        git push origin stable

        cd /git-local-repos/theme_a

        echo "update" > /git-local-repos/theme_a/README
        git add README
        git commit -m "Add README"
        git push origin master
        ;;
    "install_test:set_extensions_rb")
        cat <<EOS > /redmine/.extensions.rb
        plugin :plugin_a, git: {url: "/git-server-repos/plugin_a.git"}
EOS
        ;;
    "install_test:set_extensions_rb_with_adding_plugin_b")
        cat <<EOS > /redmine/.extensions.rb
        plugin :plugin_a, git: {url: "/git-server-repos/plugin_a.git"}
        plugin :plugin_b, git: {url: "/git-server-repos/plugin_b.git"}
EOS
        ;;
    "install_test:set_extensions_rb_with_changing_source_of_plugin_a")
        cat <<EOS > /redmine/.extensions.rb
        plugin :plugin_a, git: {url: "/git-server-repos/plugin_a.git", tag: "v0.1.0"}
        plugin :plugin_b, git: {url: "/git-server-repos/plugin_b.git"}
EOS
        ;;
esac
