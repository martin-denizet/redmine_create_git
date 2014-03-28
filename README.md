# Redmine Create Git plugin

Create and initialize a new Git repository from Redmine within seconds!

I had to create Git repositories quite often and going to the command line to initialize a repository was time-consuming, this plugin solves this problem.

If you like this plugin, you're welcome to endorse me!
[![endorse](https://api.coderwall.com/martin-denizet/endorsecount.png)](https://coderwall.com/martin-denizet)

Work sponsored by Algen, visit us at http://algen.co

## Compatibility

Compatible with Redmine 2.4.x and 2.5.x on Linux

Tested on:
* 2.4.2 stable
* 2.5.0 stable

## READ FIRST

This plugin is made to work with git SmartHTTP. It is required to have the Redmine.pm installed and configured.
I *STRONGLY* recommend you read carefully the "GIT SMART HTTP SUPPORT" section of http://www.redmine.org/projects/redmine/repository/entry/trunk/extra/svn/Redmine.pm

The git section in Apache's VirtualHost for Redmine should be as following:
```
    #From the Remine.pm Git Smart Http instructions:
    SetEnv GIT_PROJECT_ROOT /opt/gws/repos/git/
    SetEnv GIT_HTTP_EXPORT_ALL
    ScriptAlias /git/ /usr/lib/git-core/git-http-backend/

    PerlLoadModule Apache::Redmine

    <Location /git>
        Order allow,deny
        Allow from all


        AuthType Basic
        AuthName "Git repositories"
        Require valid-user

        PerlAccessHandler Apache::Authn::Redmine::access_handler
        PerlAuthenHandler Apache::Authn::Redmine::authen_handler


        ## for mysql
        RedmineDSN "DBI:mysql:database=gws;host=localhost"
        RedmineDbUser "redmine"
        RedmineDbPass "<yourpasswordhere>"

        #Enable Git Smart Http
        RedmineGitSmartHttp yes
    </Location>
```

## Features

* Create a git repository from the project Settings
* Configurable .gitignore initialization
* Configurable branches to create
* Integration with Redmine Checkout plugin

## Screenshots

* [Configuration](https://raw.github.com/martin-denizet/redmine_create_git/develop/screenshots/redmine_create_git_configuration.png)
* [New repository form](https://raw.github.com/martin-denizet/redmine_create_git/develop/screenshots/redmine_create_git_new_repo.png)
* [New repository saved with Redmine Checkout Plugin installed](https://raw.github.com/martin-denizet/redmine_create_git/develop/screenshots/redmine_create_git_created.png)

## Known Issues

* Only compatible with Linux *(Tested on Debian)*
* No validation tests on the plugin configuration page input!

## Downloading and installing the plugin

First download the plugin using git, open a terminal in your Redmine installation directory:

<tt>git clone https://github.com/martin-denizet/redmine_create_git.git ./plugins/</tt>

The plugin uses the content_for in controllers gem. It's required to run a bundle install command:
<tt>bundle install</tt>

The installation is now finished and you will be able to use the plugin after you restart your Redmine instance.

No need to migrate the database!

## Configuration

Go to your Redmine plugin configuration page. For example http://redmine.domain.com/settings/plugin/redmine_create_git
Set the path to the repositories. It must be a local path and the user running Redmine on the server must have rw permissions.
You can also configure the URL to integrate with Redmine Checkout Plugin. Tested working with [rkallensee's fork](https://github.com/rkallensee/redmine_checkout.git).

## Use

* Go to the Project Settings, Repository tab
* Click *"Quick create [Create Git plugin]"*
* Input a repository identifier
* Click *"Create"*
* Start working with git!

## Credits

Uses Clément Alexandre's content_for_in_controllers gem: https://github.com/clm-a/content_for_in_controllers

## License

GPLv2

