class Admin::FieldItemsController < Admin::BaseController
  before_action :set_series
  before_action :set_item, only: [:update, :destroy]

  def create
    @item = @series.field_items.new(field_item_params)
    if @item.save
      redirect_to admin_field_url(@series), notice: "Item added"
    else
      redirect_to admin_field_url(@series), alert: "Failed to add item"
    end
  end

  def update
    if @item.update(field_item_params)
      redirect_to admin_field_url(@series), notice: "Item updated"
    else
      redirect_to admin_field_url(@series), alert: "Failed to update item"
    end
  end

  def destroy
    @item.destroy
    redirect_to admin_field_url(@series), notice: "Item deleted"
  end

  private

  def set_series
    @series = FieldSeries.find(params[:field_id])
  end

  def set_item
    @item = @series.field_items.find(params[:id])
  end

  def field_item_params
    params.require(:field_item).permit(:kind, :caption, :position, :youtube_url, :photo)
  end
end
