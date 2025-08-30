module CheckboxHelper
  VALID_VARIANTS = (0..9).freeze
  VALID_FILL_STYLES = {
    blot: "blot",
    x: "x"
  }.freeze

  def habit_checkbox(box_variant:, fill_variant: nil, fill_style: nil)
    validate_checkbox_params!(box_variant, fill_variant, fill_style)

    content_tag :div, class: "checkbox-container" do
      safe_join([
        render("checkboxes/box_#{box_variant}"),
        render_fill_partial(fill_variant, fill_style)
      ])
    end
  end

  private

  def validate_checkbox_params!(box_variant, fill_variant, fill_style)
    # Validate box_variant (always required)
    raise ArgumentError, "box_variant must be an integer" unless box_variant.is_a?(Integer)
    raise ArgumentError, "Invalid box_variant: must be 0-9 (got #{box_variant.inspect})" unless VALID_VARIANTS.include?(box_variant)

    # Early return for unfilled checkbox (both nil is valid)
    return if fill_variant.nil? && fill_style.nil?

    # Guard against partial fill parameters
    raise ArgumentError, "fill_variant is required when fill_style is provided" if fill_variant.nil? && !fill_style.nil?
    raise ArgumentError, "fill_style is required when fill_variant is provided" if !fill_variant.nil? && fill_style.nil?

    # Validate both fill parameters when provided
    raise ArgumentError, "fill_variant must be an integer" unless fill_variant.is_a?(Integer)
    raise ArgumentError, "fill_style must be a symbol" unless fill_style.is_a?(Symbol)
    raise ArgumentError, "Invalid fill_variant: must be 0-9 (got #{fill_variant.inspect})" unless VALID_VARIANTS.include?(fill_variant)
    raise ArgumentError, "Invalid fill_style: must be #{VALID_FILL_STYLES.keys.join(', ')} (got #{fill_style.inspect})" unless VALID_FILL_STYLES.key?(fill_style)
  end

  def render_fill_partial(variant, style)
    return "" if variant.nil? && style.nil?

    partial_prefix = VALID_FILL_STYLES[style]
    render("checkboxes/#{partial_prefix}_#{variant}")
  end
end
