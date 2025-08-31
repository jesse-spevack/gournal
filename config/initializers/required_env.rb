# Check for required environment variables
if Rails.env.production? && ENV["DEMO_USER_EMAIL"].blank?
  Rails.logger.warn "DEMO_USER_EMAIL not set, using default demo@example.com"
end
