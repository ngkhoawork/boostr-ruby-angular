ActiveAdmin.register_page 'Settings' do
  title = 'Settings'
  menu label: title

  content do
    render partial: 'index', locals: { valid_settings: Setting.valid }
  end

  page_action :update, method: :post do
    settings_params = params.require(:settings).permit!

    settings_params.each do |var, value|
      setting = Setting.find_or_initialize_by(var: var)
      setting.value = value
      setting.save
    end

    flash[:success] = 'Settings was successfully updated.'
    redirect_to(:back)
  end
end
