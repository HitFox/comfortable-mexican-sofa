require 'rails/generators/active_record'

module Comfy
  module Generators
    class CmsGenerator < Rails::Generators::Base

      include Rails::Generators::Migration
      include Thor::Actions

      source_root File.expand_path('../../../../..', __FILE__)

      def generate_migration
        destination   = File.expand_path('db/migrate/01_create_cms.rb', self.destination_root)
        migration_dir = File.dirname(destination)
        destination   = self.class.migration_exists?(migration_dir, 'create_cms')

        if destination
          puts "\e[0m\e[31mFound existing cms_create.rb migration. Remove it if you want to regenerate.\e[0m"
        else
          migration_template 'db/migrate/01_create_cms.rb', 'db/migrate/create_cms.rb'
        end
      end

      def generate_initializer
        copy_file 'config/initializers/comfortable_mexican_sofa.rb',
          'config/initializers/comfortable_mexican_sofa.rb'
      end

      def generate_routing
        route_string  = "  scope ':locale', defaults: { locale: I18n.default_locale.to_s } do\n"
        route_string << "    comfy_route :cms_admin, :path => '/admin'\n\n"
        route_string << "    # Make sure this routeset is defined last\n"
        route_string << "    comfy_route :cms, :path => '/', :sitemap => false\n"
        route_string << "  end"
        route route_string[2..-1]
      end

      def generate_cms_seeds
        directory 'db/cms_fixtures', 'db/cms_fixtures'
      end

      def generate_assets
        copy_file 'app/assets/javascripts/comfy/admin/cms/custom.js.coffee',
          'app/assets/javascripts/comfy/admin/cms/custom.js.coffee'
        copy_file 'app/assets/stylesheets/comfy/admin/cms/custom.sass',
          'app/assets/stylesheets/comfy/admin/cms/custom.sass'
      end

      def show_readme
        readme 'lib/generators/comfy/cms/README'
      end

      def self.next_migration_number(dirname)
        ActiveRecord::Generators::Base.next_migration_number(dirname)
      end

      def generate_views
        template 'lib/generators/comfy/cms/templates/views/index.html.haml', "app/views/admin/base/index.html.haml"
        template 'lib/generators/comfy/cms/templates/views/show.html.haml', "app/views/admin/base/show.html.haml"
        template 'lib/generators/comfy/cms/templates/views/new.html.haml', "app/views/admin/base/new.html.haml"
        template 'lib/generators/comfy/cms/templates/views/edit.html.haml', "app/views/admin/base/edit.html.haml"
        template 'lib/generators/comfy/cms/templates/views/_collection_actions.html.haml', "app/views/admin/base/_collection_actions.html.haml"
        template 'lib/generators/comfy/cms/templates/views/_member_actions.html.haml', "app/views/admin/base/_member_actions.html.haml"
        template 'lib/generators/comfy/cms/templates/views/_right_column.html.haml', "app/views/admin/base/_right_column.html.haml"
        template 'lib/generators/comfy/cms/templates/views/_show.html.haml', "app/views/admin/base/_show.html.haml"
        template 'lib/generators/comfy/cms/templates/views/comments/_comment.html.haml', "app/views/admin/comments/_comment.html.haml"
        template 'lib/generators/comfy/cms/templates/views/comments/_comments.html.haml', "app/views/admin/comments/_comments.html.haml"
        template 'lib/generators/comfy/cms/templates/views/comments/_form.html.haml', "app/views/admin/comments/_form.html.haml"
      end

      def generate_helpers
        template 'lib/generators/comfy/cms/templates/helpers/sort_helper.rb', "app/helpers/sort_helper.rb"
      end

      def generate_models
        template 'lib/generators/comfy/cms/templates/models/concerns/commentable.rb', 'app/models/concerns/commentable.rb'
        template 'lib/generators/comfy/cms/templates/models/role.rb', 'app/models/role.rb'
        generate(:migration, 'CreateRoles identifier:string:index name:string')
      end

      def generate_controllers
        template 'lib/generators/comfy/cms/templates/controllers/base_controller.rb', "app/controllers/admin/base_controller.rb"
        template 'lib/generators/comfy/cms/templates/controllers/admins_controller.rb', "app/controllers/admin/admins_controller.rb"
      end

      def generate_controller_concerns
        template 'lib/generators/comfy/cms/templates/controllers/concerns/permitify.rb', "app/controllers/concerns/permitify.rb"
        template 'lib/generators/comfy/cms/templates/controllers/concerns/sortify.rb', "app/controllers/concerns/sortify.rb"
        template 'lib/generators/comfy/cms/templates/controllers/concerns/routify.rb', "app/controllers/concerns/routify.rb"
        template 'lib/generators/comfy/cms/templates/controllers/concerns/localizify.rb', "app/controllers/concerns/localizify.rb"
        template 'lib/generators/comfy/cms/templates/controllers/concerns/eventify.rb', "app/controllers/concerns/eventify.rb"
      end

      def generate_locales
        template 'lib/generators/comfy/cms/templates/locales/en.yml', "config/locales/en.yml"
        template 'lib/generators/comfy/cms/templates/locales/de.yml', "config/locales/de.yml"
      end

      def generate_initializers
        template 'lib/generators/comfy/cms/templates/initializers/i18n.rb', 'config/initializers/i18n.rb'
        template 'lib/generators/comfy/cms/templates/initializers/state_machine.rb', 'config/initializers/state_machine.rb'
      end

      def modify_application_controller
        sentinel = /class\ ApplicationController\ \<\ ActionController\:\:Base\n/
        in_root do
          inject_into_file 'app/controllers/application_controller.rb', "  include Routify, Sortify, Localizify\n", { after: sentinel, verbose: false, force: true }
        end
      end

      def generate_devise_install
        generate('devise:install')
        generate(:devise, 'admin')

        template 'lib/generators/comfy/cms/templates/models/admin.rb', 'app/models/admin.rb'
        generate(:migration, 'AddRoleIdAndStateToAdmin role_id:integer state:string:index')
      end
    end
  end
end
