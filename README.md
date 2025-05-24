<div align="center">
  <h1>Rexer</h1>
  <p>Redmine Extension (Plugin and Theme) manager</p>
</div>

<p align="center">
  <a href="https://github.com/hidakatsuya/rexer/actions/workflows/build.yml">
    <img src="https://github.com/hidakatsuya/rexer/actions/workflows/build.yml/badge.svg" alt="Build">
  </a>
  <a href="https://badge.fury.io/rb/rexer">
    <img src="https://badge.fury.io/rb/rexer.svg" alt="Gem Version">
  </a>
</p>

Rexer is a command-line tool for managing Redmine Extensions (Plugins and Themes).

It is mainly aimed at helping with the development of Redmine and its plugins, allowing you to define extensions in a Ruby DSL and install, uninstall, update, and switch between different sets of the extensions.

## What is Redmine Extension?

Redmine [Plugins](https://www.redmine.org/projects/redmine/wiki/Plugins) and [Themes](https://www.redmine.org/projects/redmine/wiki/Themes) are called Redmine Extensions in this tool.

## Installation

```
gem install rexer
```

## Supported Redmine

Rexer is tested with Redmine v6.0 and trunk.

## Usage

Run the following command in the root directory of the Redmine application.

```
rex init
```

This command generates a `.extensions.rb`, so define the extensions you want to install in the file like below.

```ruby
theme :bleuclair, github: { repo: "farend/redmine_theme_farend_bleuclair", branch: "master" }

plugin :redmine_issues_panel, git: { url: "https://github.com/redmica/redmine_issues_panel", tag: "v1.0.2" }
plugin :redmica_ui_extension, github: { repo: "redmica/redmica_ui_extension", ref: "4fdc298bc310be2ab295008c0ee522b0ec0e319a" }
```

Then, run the following command in the root directory of the Redmine application.

```
rex install
```

This command performs the following steps for each extension defined in the `.extensions.rb` to install it and generates a `.extensions.lock`.

For plugins:
* Load the plugin from the specified `git` or `github` repository.
* Run the `bundle install` command if the plugin has a `Gemfile`.
* Run the `bundle exec rake redmine:plugins:migrate NAME=<plugin_name>` command if the plugin has any database migration.

For themes:
* Load the theme from the specified `git` or `github` repository.

> [!NOTE]
> The `.extensions.lock` is a file for preserving the state of installed extensions, but not the version of an extension.

If you want to uninstall the extensions, run the following command.

```
rex uninstall
```

This command uninstalls the extensions and deletes the `.extensions.lock`.

## Commands

```
$ rex
Commands:
  rex edit                    # Edit .extensions.rb
  rex envs                    # Show the list of environments and their extensions defined in .extensions.rb
  rex help [COMMAND]          # Describe available commands or one specific command
  rex init                    # Create a new .extensions.rb file
  rex install [env]           # Install the definitions in .extensions.rb for the specified environment
  rex reinstall [extension]   # Uninstall extensions for the currently installed environment and install them again
  rex state                   # Show the current state of the installed extensions
  rex switch [env]            # Uninstall extensions for the currently installed environment and install extensions for the specified environment
  rex uninstall               # Uninstall extensions for the currently installed environment based on the state in .extensions.lock and remove the lock file
  rex update [extensions...]  # Update extensions for the currently installed environment to the latest version if extensions are updateable. If no extensions are specified, all extensions are updated
  rex version                 # Show Rexer version

Options:
  -v, [--verbose], [--no-verbose], [--skip-verbose]  # Detailed output
  -q, [--quiet], [--no-quiet], [--skip-quiet]        # Minimal output
```

### rex install [env]

Installs extensions in the specified ENV environment and makes them available for use. Specifically, it does the following:

If the specified ENV is NOT currently installed, it adds all extensions in the ENV environment in `.extensions.rb`.

If the specified ENV is currently installed, it compares the current `.extensions.lock` with `.extensions.rb` and does the following:
* Installs additional extensions (the `installed` hook is executed).
* Uninstalls deleted extensions (the `uninstalled` hook is executed).
* Reload extensions whose source settings has changed (for example, the `branch` or `tag` has changed) and runs the database migration if necessary.

> [!TIP]
> Execute the install command when running the rex command without a subcommand.

### rex update [extensions...]

Loads `.extensions.lock` and updates the currently installed extensions to the latest version. `.extensions.rb` is NOT referenced in this command.

### Short commands available

The command to execute is determined by a forward match, so you can use like the following short commands.

```
rex ins # means install
rex st  # maens state
rex sw  # means switch
rex e   # means envs
rex v   # means version

and more...
```

## Advanced Usage

### Defining for each environment and extension

You can define an environment and extensions for each environment using the `env ... do - end` block.

```ruby
plugin :redmine_issues_panel, github: { repo: "redmica/redmine_issues_panel", branch: "master" }

env :stable do
  plugin :redmine_issues_panel, github: { repo: "redmica/redmine_issues_panel", tag: "v1.0.2" }
end

env :default, :stable do
  theme :bleuclair, github: { repo: "farend/redmine_theme_farend_bleuclair" }
end
```

Definitions other than `env ... do - end` are implicitly defined as `env :default do - end`. Therefore, the above is resolved as follows:

* default env
  * bleuclair (farend/redmine_theme_farend_bleuclair@main)
  * redmine_issues_panel (redmica/redmine_issues_panel@master)
* stable env
  * bleuclair (farend/redmine_theme_farend_bleuclair@main)
  * redmine_issues_panel (redmica/redmine_issues_panel@v1.0.2)

If you want to install extensions for the `default` environment, run the following command.

```
rex install
or
rex install default
```

Similarly, if you want to install extensions for the `stable` environment, run the following command.

```
rex install stable
```

In addition, you can switch between environments.

```
rex switch stable
or
rex install stable
```

The above command uninstalls the extensions for the currently installed environment and installs the extensions for the `stable` environment.

In addition, you can define as many environments as you like, and list the defined environments with the `rex envs` command.

```
$ rex envs
default
  bleuclair (farend/redmine_theme_farend_bleuclair@main)
  redmine_issues_panel (redmica/redmine_issues_panel@master)

stable
  bleuclair (farend/redmine_theme_farend_bleuclair@main)
  redmine_issues_panel (redmica/redmine_issues_panel@v1.0.2)
```

### Defining hooks

You can define hooks for each extension.

```ruby
plugin :redmica_s3, github: { repo: "redmica/redmica_s3" } do
  installed do
    Pathname.new("config", "s3.yml").write <<~YAML
      access_key_id: ...
    YAML
  end

  uninstalled do
    Pathname.new("config", "s3.yml").delete
  end
end
```

### Configuring the command prefix

You can set a prefix for the commands such as `bundle install` that Rexer executes with the `REXER_COMMAND_PREFIX` environment variable.

```
export REXER_COMMAND_PREFIX="docker compose exec -T app"
```

In the above case, the `bin/rails redmine:plugins:migrate` command is executed as `docker compose exec -T app bin/rails redmine:plugins:migrate`.

## Syntax for extensions.rb

### Plugin

```ruby
plugin :plugin_name, <source>: { ... }
```

### Theme

```ruby
theme :theme_name, <source>: { ... }
```

### Source

#### Git

```ruby
plugin :redmine_issues_panel, git: { url: "https://github.com/redmica/redmine_issues_panel" }
```
```ruby
# Specify the branch
plugin :redmine_issues_panel, git: { url: "https://github.com/redmica/redmine_issues_panel", branch: "main" }
# Specify the tag
plugin :redmine_issues_panel, git: { url: "https://github.com/redmica/redmine_issues_panel", tag: "v1.0.0" }
# Specify the commit
plugin :redmine_issues_panel, git: { url: "https://github.com/redmica/redmine_issues_panel", ref: "5cfb8ccbabb2fad2c8f2273a4dda3f16ef2de124" }
```

#### GitHub

```ruby
plugin :redmine_issues_panel, github: { repo: "redmica/redmine_issues_panel", tag: "v1.0.0" }
```

### Env

```ruby
plugin :redmine_issues_panel, github: { repo: "redmica/redmine_issues_panel" }

# This is the same as the above.
env :default do
  plugin :redmine_issues_panel, github: { repo: "redmica/redmine_issues_panel" }
end

env :stable do
  plugin :redmine_issues_panel, github: { repo: "redmica/redmine_issues_panel", tag: "v1.0.2" }
end

env :default, :stable do
  theme :bleuclair, github: { repo: "farend/redmine_theme_farend_bleuclair" }
end
```

### Hooks

```ruby
plugin :redmine_issues_panel, github: { repo: "redmica/redmine_issues_panel" } do
  installed do
    puts "The plugin has been installed."
  end

  uninstalled do
    puts "The plugin has been uninstalled."
  end
end

theme :bleuclair, github: { repo: "farend/redmine_theme_farend_bleuclair" } do
  installed do
    puts "The theme has been installed."
  end

  uninstalled do
    puts "The theme has been uninstalled."
  end
end
```

## Developing

### Running the command

You can run the command in your local environment without installing the gem as follows.

Setting up the development environment.

```
$ git clone <this repository>
$ cd rexer
$ bundle install
```

Running the command.

```
$ cd /path/to/your-local-redmine-source
$ /your-local-rexer-source/bin/dev state
```

### Running tests

First, you need to build the docker image for the integration tests.

```
rake test:prepare_integration
```

Then, you can run all tests.

```
rake test
```

Or, you can only the integration tests as follows.

```
rake test:integration
```

### Formatting and Linting code

This project uses [Standard](https://github.com/standardrb/standard) for code formatting and linting. You can format and check the code by running the following commands.

```
rake standard
rake standard:fix
```

### Profiling

Print the call-stack profile.

```
$ PROFILE=s /your-local-rexer-source/bin/dev state
...

== Profile ==
==================================
  Mode: wall(1000)
  Samples: 298 (1.97% miss rate)
  GC: 36 (12.08%)
==================================
     TOTAL    (pct)     SAMPLES    (pct)     FRAME
       261  (87.6%)         147  (49.3%)     Kernel#require
       ...
```

Print the benchmark.

```
$ PROFILE=b /your-local-rexer-source/bin/dev state
...

== Benchmark ==
      user     system      total        real
  0.253115   0.030599   0.283714 (  0.283681)
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hidakatsuya/rexer.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
