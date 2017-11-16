module PagesHelper
  def paginate(relation)
    relation.offset(offset).limit(per_page)
  end

  def page
    params[:page] || 1
  end

  def per_page
    params[:per_page] || 30
  end

  def offset
    (page - 1) * per_page
  end
end
