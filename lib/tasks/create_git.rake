desc <<-END_DESC
Create Git repo

Available options:
  * workdir             => location for the Git repository
  * projectidentifier   => Identifier of the project
  * repoidentifier      => Identifier of the repository to create

Example:
  rake redmine:create_git workdir=/var/repos/git/ projectidentifier=project repoidentifier=newrepo RAILS_ENV="production"
END_DESC


class CreateGit

  def self.create_git(options={})
    workdir = options[:workdir]+"/" unless options[:workdir][-1,1]=='/'
    projectidentifier = options[:projectidentifier]
    repoidentifier = options[:repoidentifier]
    repo_complete_identifier=projectidentifier+"."+repoidentifier
    repo_fullpath=workdir+repo_complete_identifier
    project=Project.find(:first,:conditions => ["identifier = ?",projectidentifier])
    puts projectidentifier
    puts "Creating repo in "+repo_fullpath+" for project "+project.name

    if project and create_repo(repo_fullpath)
      repo=Repository.factory("Git")
      repo.project = project
      repo.url = workdir+project.identifier+"."+repoidentifier
      repo.login = ""
      repo.password = ""
      repo.root_url = "/opt/redmine/repos/git/"+project.identifier+"."+repoidentifier
      repo.checkout_settings = HashWithIndifferentAccess.new
      repo.checkout_settings["checkout_display_command"]="0"
      repo.checkout_settings["checkout_protocols"]=[{"command"=>"git clone", "is_default"=>"1", "protocol"=>"Git", "fixed_url"=>"https://gws.irec.cn/git/"+project.identifier+"."+repoidentifier, "access"=>"permission"}]
      repo.checkout_settings["checkout_description"]="The data contained in this repository can be downloaded to your computer using one of several clients.\nPlease see the documentation of your version control software client for more information.\n\nPlease select the desired protocol below to get the URL.\n"
      repo.checkout_settings["checkout_overwrite"]="1"
      checkout_overwrite = "1"
      repo.path_encoding = ""
      repo.log_encoding = nil
      repo.extra_info = {"extra_report_last_commit"=>"0"}
      repo.identifier = repoidentifier
      repo.is_default = false
      if repo.save!
        puts "Saved in database"
      else
        puts "Error saving"
      end
    end
  end

  def self.create_repo(repo_fullpath)
    if File.exist?(repo_fullpath)
      puts "Repository in '"+repo_fullpath+"' already exists!"
      return false
    else
      temporary_clone='/tmp/tmp_create_git/'
      system("rm -Rf #{temporary_clone}")
      system("mkdir #{repo_fullpath}")
      system("cd #{repo_fullpath} && git init --bare")
      system("git clone #{repo_fullpath} #{temporary_clone}");
      system('cp /opt/redmine/scripts/scm-integration/gitignore '+temporary_clone+"/.gitignore");
      system("cd #{temporary_clone} && git add .gitignore && git commit -m 'First Commit' && git push origin master");
      system("cd #{temporary_clone} && git checkout -b develop && git push origin develop");
      system("rm -Rf  #{temporary_clone}")
      system("chown -R www-data:www-data #{repo_fullpath}")
      puts "Installing hooks"
      system('/opt/redmine/scripts/scm-integration/hook-installer.pl > /dev/null')
      puts "Creation finished"
    end
    return true
  end
end

namespace :redmine do
  task :create_git => :environment do
    if(ENV['workdir']&&ENV['projectidentifier']&&ENV['repoidentifier'])
      options = {}
      options[:workdir] = ENV['workdir']
      options[:projectidentifier] = ENV['projectidentifier']
      options[:repoidentifier] = ENV['repoidentifier']

      CreateGit.create_git(options)
    else
      puts "Parameter(s) missing"+desc
    end
  end
end
