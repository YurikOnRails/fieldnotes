class Admin::NowsController < Admin::BaseController
  def edit
    @now_entry        = NowEntry.latest || NowEntry.new(published_at: Time.current)
    @previous_entries = NowEntry.previous.limit(10)
    render Views::Admin::Nows::EditView.new(now_entry: @now_entry, previous_entries: @previous_entries)
  end

  def update
    @now_entry = NowEntry.new(now_entry_params.merge(published_at: Time.current))
    if @now_entry.save
      redirect_to edit_admin_now_url, notice: "Now page updated"
    else
      @previous_entries = NowEntry.previous.limit(10)
      render Views::Admin::Nows::EditView.new(now_entry: @now_entry, previous_entries: @previous_entries),
             status: :unprocessable_entity
    end
  end

  private

  def now_entry_params
    params.require(:now_entry).permit(:body)
  end
end
