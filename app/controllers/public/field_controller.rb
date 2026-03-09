class Public::FieldController < Public::BaseController
  rate_limit to: 60, within: 1.minute, only: :index

  def index
    @series = FieldSeries.includes(field_items: { photo_attachment: :blob }).order(created_at: :desc)
    fresh_when @series
    render Views::Public::Field::IndexView.new(series: @series)
  end

  def show
    @series = FieldSeries.includes(field_items: { photo_attachment: :blob }).find_by!(slug: params[:slug])
    Rails.event.notify("field.viewed", field_series_id: @series.id, path: request.path)
    fresh_when @series
    render Views::Public::Field::ShowView.new(series: @series)
  end
end
