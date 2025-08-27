module CheckboxHelper
  VALID_VARIANTS = (0..9).freeze
  VALID_FILL_STYLES = {
    blot: "blotch",
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
    raise ArgumentError, "Invalid box_variant: must be 0-9 (got #{box_variant})" unless VALID_VARIANTS.include?(box_variant)

    if fill_variant && !VALID_VARIANTS.include?(fill_variant)
      raise ArgumentError, "Invalid fill_variant: must be 0-9 (got #{fill_variant})"
    end

    if fill_style && !VALID_FILL_STYLES.key?(fill_style)
      raise ArgumentError, "Invalid fill_style: must be #{VALID_FILL_STYLES.keys.join(', ')} (got #{fill_style})"
    end
  end

  def render_fill_partial(variant, style)
    return "" unless variant && style

    partial_prefix = VALID_FILL_STYLES[style]
    render("checkboxes/#{partial_prefix}_#{variant}")
  end
end
