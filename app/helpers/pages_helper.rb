module PagesHelper
  def paginate(relation)
    relation.offset(offset).limit(per)
  end

  private

  def page
    params[:page] ? params[:page].to_i : default_page
  end

  def per
    params[:per] ? params[:per].to_i : default_per
  end

  def offset
    (page - 1) * per
  end

  def default_page
    1
  end

  def default_per
    10
  end
end
