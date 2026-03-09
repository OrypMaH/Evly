# app/helpers/pagy_semantic_renderer.rb
class PagySemanticRenderer < Pagy::Frontend
  def pagy_nav(pagy)
    html = %(<div class="ui pagination menu">)
    
    # Кнопка "Предыдущая"
    if pagy.prev
      html << %(<a class="item" href="#{pagy_url_for(pagy, pagy.prev)}">← Назад</a>)
    else
      html << %(<a class="item disabled">← Назад</a>)
    end
    
    # Номера страниц
    pagy.series.each do |item|
      if item.is_a?(Integer)
        html << %(<a class="item #{'active' if pagy.page == item}" href="#{pagy_url_for(pagy, item)}">#{item}</a>)
      elsif item.is_a?(String)
        html << %(<div class="item disabled">#{item}</div>)
      end
    end
    
    # Кнопка "Следующая"
    if pagy.next
      html << %(<a class="item" href="#{pagy_url_for(pagy, pagy.next)}">Вперед →</a>)
    else
      html << %(<a class="item disabled">Вперед →</a>)
    end
    
    html << %(</div>)
    html.html_safe
  end
end