ActiveAdmin.register_page "Dashboard" do

  menu :priority => 1, :label => proc{ I18n.t("active_admin.dashboard") }

  content :title => proc{ I18n.t("active_admin.dashboard") } do

    columns do
      column do
        panel "Recent Connections" do
          table_for Lead.order("created_at desc").limit(10).map do
            column do |lead|
              link_to("#{ lead.user } added #{ lead.response_id } #{ time_ago_in_words lead.created_at } ago", "/admin/connections/#{ lead.id }")
            end
          end
        end
      end

      column do
        panel "New Users" do
          table_for User.order("created_at desc").limit(10).map do
            column do |user|
              link_to("#{ user } signed in for the first time #{ time_ago_in_words user.created_at } ago", "/admin/users/#{ user.id }")
            end
          end
        end
      end

      column do
        panel "Info" do
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
