class Api::V1::CountriesController < ApiController
  def index
    render json: { countries: ISO3166::Country.all_translated }
  end
end
