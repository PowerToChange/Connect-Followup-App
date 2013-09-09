ActiveAdmin.register User do

  show do
    panel "User" do
      attributes_table_for user do
        user.attributes.keys.each { |column| row column }
      end
    end

    panel "Connections" do
      table_for user.leads do
        column "Survey" do |lead| lead.survey.title end
        column "Activity ID" do |lead| lead.response_id end
        column "Contact ID" do |lead| lead.contact_id end
        column "Status" do |lead| lead.status end
        column "Engagement Level" do |lead| engagement_level_label(lead.engagement_level) end
        column "Created At" do |lead| lead.created_at end
        column "Updated At" do |lead| lead.updated_at end
      end
    end

    panel "Associated Schools" do
      table_for user.schools.sort_by(&:display_name) do
        column "School Name" do |school|
          school.display_name
        end
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :guid
    end
    f.actions
  end

end
