ActiveAdmin.register_page "Dashboard" do

  menu :priority => 1, :label => proc{ I18n.t("active_admin.dashboard") }

  content :title => proc{ I18n.t("active_admin.dashboard") } do

    columns do
      column do
        panel "Recent Connections" do
          table_for Lead.order("created_at desc").limit(10).map do
            column do |lead|
              link_to("<strong>#{ lead.user }</strong> added a connection #{ time_ago_in_words lead.created_at } ago (#{ lead.survey.title })".html_safe, "/admin/connections/#{ lead.id }")
            end
          end
        end
      end

      column do
        panel "New Users" do
          table_for User.order("created_at desc").limit(10).map do
            column do |user|
              link_to("<strong>#{ user }</strong> signed in for the first time #{ time_ago_in_words user.created_at } ago".html_safe, "/admin/users/#{ user.id }")
            end
          end
        end
      end

      column do
        panel "Recently Completed Connections" do
          table_for Lead.order("updated_at desc").where("engagement_level IS NOT NULL").limit(10).map do
            column do |lead|
              link_to("<strong>#{ lead.user }</strong> connected with engagement level <strong>#{ engagement_level_label(lead.engagement_level) }</strong> #{ time_ago_in_words lead.updated_at } ago".html_safe, "/admin/connections/#{ lead.id }")
            end
          end
        end
      end

      column do
        panel "Counts" do
          ul do
            li pluralize Lead.count, 'Connection'
            li pluralize User.count, 'User'
            li pluralize Survey.count, 'Survey'
            li pluralize School.count, 'School'
          end
        end
      end
    end

  end # content
end
