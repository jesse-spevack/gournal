require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "current_date returns date in specified timezone" do
    Current.timezone = "America/Denver"

    Time.use_zone("UTC") do
      travel_to Time.zone.parse("2025-10-08 06:00:00") do
        assert_equal 2025, current_date.year
        assert_equal 10, current_date.month
        assert_equal 8, current_date.day
      end
    end
  end

  test "current_date falls back to UTC when no timezone set" do
    Current.timezone = nil

    Time.use_zone("UTC") do
      travel_to Time.zone.parse("2025-10-08 12:00:00") do
        assert_equal 2025, current_date.year
        assert_equal 10, current_date.month
        assert_equal 8, current_date.day
      end
    end
  end
end
