module PagesHelper
  def paginate(relation)
    relation.offset(offset).limit(limit)
  end

  private

  def page
    params[:page] ? params[:page].to_i : default_page
  end

  def limit
    params[:limit] ? params[:limit].to_i : default_limit
  end

  def offset
    (page - 1) * limit
  end

  def default_page
    1
  end

  def default_limit
    10
  end
end
