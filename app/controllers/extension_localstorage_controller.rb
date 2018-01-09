class ExtensionLocalstorageController < ApplicationController
  skip_before_filter :authenticate_user!, only: :index
  def index
  	render layout: nil, file: 'app/views/layouts/extension_localstorage'
  end
end