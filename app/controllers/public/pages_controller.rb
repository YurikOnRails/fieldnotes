class Public::PagesController < Public::BaseController
  def about
    render Views::Public::Pages::AboutView.new
  end

  def contact
    render Views::Public::Pages::ContactView.new
  end

  def uses
    render Views::Public::Pages::UsesView.new
  end
end
