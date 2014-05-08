require_dependency 'projects_controller'

module CreateGit
  module ProjectsControllerPatch
    def self.included(base) # :nodoc:
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable

        alias_method_chain :settings, :create_git
      end
    end

    module InstanceMethods
      def settings_with_create_git

        content_for :header_tags, "<script type='text/javascript'>
$( document ).ready(function() {
    $('#tab-content-repositories p').append( '#{view_context.link_to(I18n.t('buttons.quick_create'),{:controller=>'create_git', :action=>'new', :project_id=>@project.identifier},{:class=>'icon icon-add'})}' );
});
</script>".html_safe

        settings_without_create_git
      end

    end
  end
end

ProjectsController.send(:include, CreateGit::ProjectsControllerPatch)
