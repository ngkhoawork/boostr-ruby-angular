class Api::CountriesController < ApplicationController
  def index
    render json: { countries: ISO3166::Country.all_translated }
  end
end