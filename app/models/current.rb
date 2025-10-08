class Current < ActiveSupport::CurrentAttributes
  attribute :session, :timezone
  delegate :user, to: :session, allow_nil: true

  def timezone
    @timezone || "UTC"
  end
end
