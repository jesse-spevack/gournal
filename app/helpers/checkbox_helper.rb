module CheckboxHelper
  VALID_VARIANTS = (0..9).freeze
  VALID_FILL_STYLES = {
    blot: "blot",
    x: "x"
  }.freeze

  VARIANT_ERROR_MESSAGE = "Invalid variant: must be 0-9 (got %{value})".freeze
  FILL_STYLE_ERROR_MESSAGE = "Invalid fill_style: must be #{VALID_FILL_STYLES.keys.join(', ')} (got %{value})".freeze

  def habit_checkbox(box_variant:, fill_variant: nil, fill_style: nil)
    validate_checkbox_params!(box_variant, fill_variant, fill_style)

    content_tag :div, class: "checkbox-container" do
      safe_join([
        render("checkboxes/box_#{box_variant}"),
        render_fill_partial(fill_variant, fill_style)
      ])
    end
  end

  def render_habit_checkbox(entry, css_class: nil)
    raise ArgumentError, "entry is required" if entry.nil?

    entry.render_checkbox_svg(css_class: css_class)
  end

  private

  def validate_checkbox_params!(box_variant, fill_variant, fill_style)
    validate_variant!("box_variant", box_variant)

    return if both_fill_params_nil?(fill_variant, fill_style)

    validate_fill_params_consistency!(fill_variant, fill_style)
    validate_variant!("fill_variant", fill_variant)
    validate_fill_style!(fill_style)
  end

  def validate_variant!(param_name, variant)
    raise ArgumentError, "#{param_name} must be an integer" unless variant.is_a?(Integer)
    raise ArgumentError, VARIANT_ERROR_MESSAGE % { value: variant.inspect } unless VALID_VARIANTS.include?(variant)
  end

  def both_fill_params_nil?(fill_variant, fill_style)
    fill_variant.nil? && fill_style.nil?
  end

  def validate_fill_params_consistency!(fill_variant, fill_style)
    raise ArgumentError, "fill_variant is required when fill_style is provided" if fill_variant.nil? && !fill_style.nil?
    raise ArgumentError, "fill_style is required when fill_variant is provided" if !fill_variant.nil? && fill_style.nil?
  end

  def validate_fill_style!(fill_style)
    raise ArgumentError, "fill_style must be a symbol" unless fill_style.is_a?(Symbol)
    raise ArgumentError, FILL_STYLE_ERROR_MESSAGE % { value: fill_style.inspect } unless VALID_FILL_STYLES.key?(fill_style)
  end

  def render_fill_partial(variant, style)
    return "" if variant.nil? && style.nil?

    partial_prefix = VALID_FILL_STYLES[style]
    render("checkboxes/#{partial_prefix}_#{variant}")
  end
end
