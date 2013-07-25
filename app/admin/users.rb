ActiveAdmin.register User do

  show do
    panel "User" do
      attributes_table_for user do
        user.attributes.keys.each { |column| row column }
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

end
