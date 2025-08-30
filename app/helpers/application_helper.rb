module ApplicationHelper
  def month_grid_path(year:, month:)
    "/habits/1?year=#{year}&month=#{month}"
  end
end
