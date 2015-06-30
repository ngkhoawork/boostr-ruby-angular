ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }

  content title: proc{ I18n.t("active_admin.dashboard") } do
    columns do
      column do
        panel "Current SuperAdmins" do
          ul do
            User.where(roles_mask: 3).each do |user|
              li link_to(user.email, admin_user_path(user))
            end
          end
        end
      end
    end
  end
end
