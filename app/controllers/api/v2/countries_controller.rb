class Api::V2::CountriesController < ApiController
  def index
    render json: { countries: ISO3166::Country.all_translated }
  end
end
