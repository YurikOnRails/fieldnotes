class Admin::FieldController < Admin::BaseController
  before_action :set_series, only: [:show, :edit, :update, :destroy]

  def index
    @series = FieldSeries.includes(field_items: :photo_attachment).order(created_at: :desc)
    render Views::Admin::Field::IndexView.new(series: @series)
  end

  def show
    render Views::Admin::Field::ShowView.new(series: @series)
  end

  def new
    @series = FieldSeries.new
    render Views::Admin::Field::NewView.new(series: @series)
  end

  def create
    @series = FieldSeries.new(field_series_params)
    if @series.save
      redirect_to admin_field_url(@series), notice: "Series created"
    else
      render Views::Admin::Field::NewView.new(series: @series), status: :unprocessable_entity
    end
  end

  def edit
    render Views::Admin::Field::EditView.new(series: @series)
  end

  def update
    if @series.update(field_series_params)
      redirect_to admin_field_url(@series), notice: "Series updated"
    else
      render Views::Admin::Field::EditView.new(series: @series), status: :unprocessable_entity
    end
  end

  def destroy
    @series.destroy
    redirect_to admin_field_index_url, notice: "Series deleted"
  end

  private

  def set_series
    @series = FieldSeries.includes(field_items: :photo_attachment).find(params[:id])
  end

  def field_series_params
    params.require(:field_series).permit(:title, :description, :kind,
                                         :location, :taken_on, :latitude, :longitude)
  end
end
