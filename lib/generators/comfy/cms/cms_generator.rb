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
        route_string  = "  comfy_route :cms_admin, :path => '/admin'\n\n"
        route_string << "  # Make sure this routeset is defined last\n"
        route_string << "  comfy_route :cms, :path => '/', :sitemap => false\n"
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
      end

      def generate_helpers
        template 'lib/generators/comfy/cms/templates/helpers/sort_helper.rb', "app/helpers/sort_helper.rb"
      end

      def generate_base_controller
        template 'lib/generators/comfy/cms/templates/controllers/base_controller.rb', "app/controllers/admin/base_controller.rb"
        template 'lib/generators/comfy/cms/templates/controllers/concerns/permitify.rb', "app/controllers/concerns/permitify.rb"
        template 'lib/generators/comfy/cms/templates/controllers/concerns/sortify.rb', "app/controllers/concerns/sortify.rb"
        template 'lib/generators/comfy/cms/templates/controllers/concerns/routify.rb', "app/controllers/concerns/routify.rb"
      end
    end
  end
end
