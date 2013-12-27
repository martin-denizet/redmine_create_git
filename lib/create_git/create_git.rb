class GitCreator

  def self.create_git(project, repo_identifier, is_default)
    repo_path_base = Setting.plugin_redmine_create_git['repo_path']
    repo_path_base += '/' unless repo_path_base[-1, 1]=='/'

    repo_url_base = Setting.plugin_redmine_create_git['repo_url']
    if (defined?(Checkout) and not repo_url_base.nil?)
      repo_url_base += '/' unless repo_url_base[-1, 1]=='/'
    end

    project_identifier = project.identifier

    new_repo_name = project_identifier
    new_repo_name += ".#{repo_identifier}" unless repo_identifier.empty?

    new_repo_path = repo_path_base + new_repo_name


    Rails.logger.info "Creating repo in #{new_repo_path} for project #{project.name}"

    if project and create_repo(new_repo_path)
      repo=Repository.factory('Git')
      repo.project = project
      repo.url = repo_path_base+new_repo_name
      repo.login = ''
      repo.password = ''
      repo.root_url = new_repo_path
      if (defined?(Checkout))
        repo.checkout_settings = HashWithIndifferentAccess.new
        repo.checkout_settings['checkout_display_command']="0"
        repo.checkout_settings['checkout_protocols']=[{'command' => 'git clone', 'is_default' => '1', 'protocol' => 'Git', 'fixed_url' => repo_url_base+new_repo_name, 'access' => 'permission'}] unless  repo_url_base.nil?
        repo.checkout_settings['checkout_description']="The data contained in this repository can be downloaded to your computer using one of several clients.\nPlease see the documentation of your version control software client for more information.\n\nPlease select the desired protocol below to get the URL.\n"
        repo.checkout_settings['checkout_overwrite']='1'
        repo.checkout_overwrite = '1'
      end
      repo.path_encoding = ''
      repo.log_encoding = nil
      repo.extra_info = {'extra_report_last_commit' => '0'}
      repo.identifier = repo_identifier
      repo.is_default = is_default
      return repo
    end

  end

  def self.create_repo(repo_fullpath)
    if File.exist?(repo_fullpath)
      Rails.logger.error "Repository in '#{repo_fullpath}' already exists!"
      raise I18n.t('errors.repo_already_exists',{path:repo_fullpath})
    else
      temporary_clone='/tmp/tmp_create_git/'
      system("rm -Rf #{temporary_clone}")
      system("mkdir #{repo_fullpath}")
      system("cd #{repo_fullpath} && git init --bare")
      system("git clone #{repo_fullpath} #{temporary_clone}");
      #system("cp /opt/redmine/scripts/scm-integration/gitignore #{temporary_clone}/.gitignore");
      File.open("#{temporary_clone}/.gitignore", 'w') { |f| f.write(Setting.plugin_redmine_create_git['gitignore']) }

      system("cd #{temporary_clone} && git add .gitignore && git commit -m 'First Commit' && git push origin master");
      #Create branches
      Setting.plugin_redmine_create_git['branches'].gsub(/\r/, '').split(/\n/).each do |branch|
        Rails.logger.info "Adding branch #{branch}"
        system("cd #{temporary_clone} && git checkout -b #{branch} && git push origin #{branch}");
      end
      system("rm -Rf  #{temporary_clone}")
      #system("chown -R www-data:www-data #{repo_fullpath}")
      #puts "Installing hooks"
      #system('/opt/redmine/scripts/scm-integration/hook-installer.pl > /dev/null')
      Rails.logger.info 'Creation finished'
    end
    return true
  end
end