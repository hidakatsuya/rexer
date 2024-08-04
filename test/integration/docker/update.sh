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
esac
