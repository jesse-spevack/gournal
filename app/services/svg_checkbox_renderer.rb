class SvgCheckboxRenderer
  # SVG constants
  DEFAULT_CSS_CLASS = "checkbox__box".freeze
  BOX_PATH_CLASS = "checkbox__box-path".freeze
  X_MARK_CLASS = "checkbox__x-path".freeze
  BLOT_CLASS = "checkbox__fill".freeze
  MARK_WRAPPER_CLASS = "checkbox__mark".freeze

  # SVG attributes
  VIEWBOX = "0 0 24 24".freeze
  STROKE_ATTRIBUTES = {
    fill: "none",
    stroke: "var(--ink-primary)",
    "stroke-width" => "var(--stroke-width-base)",
    "stroke-linecap" => "round",
    "stroke-linejoin" => "round",
    opacity: "var(--opacity-checkbox)"
  }.freeze

  X_MARK_ATTRIBUTES = {
    fill: "none",
    stroke: "var(--ink-hover)",
    "stroke-linecap" => "round",
    "stroke-linejoin" => "round"
  }.freeze

  BLOT_ATTRIBUTES = {
    fill: "var(--ink-primary)",
    opacity: "0.71"
  }.freeze

  def self.call(box_path:, check_path: nil, check_type: nil, checked: false, css_class: nil)
    new.render(box_path: box_path, check_path: check_path, check_type: check_type, checked: checked, css_class: css_class)
  end

  def initialize
    # Empty initialization for backward compatibility with tests
  end

  def render(box_path:, check_path: nil, check_type: nil, checked: false, css_class: nil)
    @box_path = box_path
    @check_path = check_path
    @check_type = check_type
    @checked = checked
    @css_class = css_class || DEFAULT_CSS_CLASS

    validate_parameters!

    if @checked
      generate_checked_svg
    else
      generate_unchecked_svg
    end
  end

  private

  def validate_parameters!
    raise ArgumentError, "box_path is required" if @box_path.nil? || @box_path.empty?

    return unless @checked

    raise ArgumentError, "check_path is required when checked is true" if @check_path.nil? || @check_path.empty?
    raise ArgumentError, "check_type is required when checked is true" if @check_type.nil?
    raise ArgumentError, "check_type must be :x_mark or :blot" unless [ :x_mark, :blot ].include?(@check_type)
  end

  def generate_unchecked_svg
    <<~SVG.strip
      <svg class="#{@css_class}" viewBox="#{VIEWBOX}">
        #{generate_box_path}
      </svg>
    SVG
  end

  def generate_checked_svg
    <<~SVG.strip
      <svg class="#{@css_class}" viewBox="#{VIEWBOX}">
        #{generate_box_path}
        #{generate_check_element}
      </svg>
    SVG
  end

  def generate_box_path
    attributes_string = build_attributes_string(STROKE_ATTRIBUTES)
    <<~PATH.strip
      <path class="#{BOX_PATH_CLASS}" d="#{@box_path}" #{attributes_string} />
    PATH
  end

  def generate_check_element
    check_class_name = @check_type == :x_mark ? X_MARK_CLASS : BLOT_CLASS
    attributes = @check_type == :x_mark ? X_MARK_ATTRIBUTES : BLOT_ATTRIBUTES
    attributes_string = build_attributes_string(attributes)

    <<~PATH.strip
      <g class="#{MARK_WRAPPER_CLASS}">
        <path class="#{check_class_name}" d="#{@check_path}" #{attributes_string} />
      </g>
    PATH
  end

  def build_attributes_string(attributes)
    attributes.map { |key, value| "#{key}=\"#{value}\"" }.join(" ")
  end
end
