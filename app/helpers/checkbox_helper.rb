module CheckboxHelper
  def habit_checkbox(box_variant:, fill_variant: nil, fill_style: nil)
    content_tag :div, class: "checkbox-container" do
      # Always render the box outline
      box_html = render "checkboxes/box_#{box_variant}"
      
      # Optionally add fill on top
      if fill_variant && fill_style
        fill_html = case fill_style
                     when :blot 
                       render "checkboxes/blotch_#{fill_variant}"  
                     when :x 
                       render "checkboxes/x_#{fill_variant}"
                     else
                       ""
                     end
        box_html + fill_html
      else
        box_html
      end
    end
  end
end