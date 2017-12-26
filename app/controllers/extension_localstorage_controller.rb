class ExtensionLocalstorageController < ApplicationController
  skip_before_filter :authenticate_user!, only: :index
  def index
  	render layout: 'extension_localstorage'
  end
end