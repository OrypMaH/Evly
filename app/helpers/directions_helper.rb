module DirectionsHelper
    def direction_color(direction_id)
        return '#ccc' unless direction_id
    
        # Генерируем цвет на основе ID направления
        colors = [
        '#2185d0', # синий
        '#21ba45', # зеленый
        '#db2828', # красный
        '#f2711c', # оранжевый
        '#00b5ad', # бирюзовый
        '#6435c9', # фиолетовый
        '#a333c8', # пурпурный
        '#e03997', # розовый
        '#a5673f', # коричневый
        '#767676'  # серый
        ]
        
        colors[direction_id % colors.length]
    end
  
    # Форматирование направления с иконкой
    def format_direction(direction)
        return content_tag(:span, 'Не указано', class: 'direction-label ui small label') unless direction
            
            content_tag(:div, class: 'ui horizontal list') do
            concat(content_tag(:div, class: 'item') do
                content_tag(:div, direction.name, 
                        data: { tooltip: direction.department.name, position: 'top left' }, 
                        class: 'direction-label ui small label', 
                        style: "background-color: #{direction_color(direction.id)}; color: white;")
            end)
        end
    end
    def render_direction_actions(direction)
        
        buttons = []

        if can?(:edit, direction)
            buttons << link_to(edit_department_direction_path(direction.department, direction), 
                        class: 'ui icon button', 
                        title: 'Редактировать') do
                            content_tag(:i, '', class: 'edit icon')
                        end
        end
            # Кнопка удаления мероприятия
        if can?(:delete, direction)
            buttons << link_to(direction_path(direction), 
                        method: :delete,
                        class: 'ui icon negative button',
                        title: 'Удалить',
                        data: { confirm: "Удалить направление воспитательной работы '#{direction.name}'? Это действие нельзя отменить." }) do
                            content_tag(:i, '', class: 'trash icon')
                        end
        end

        safe_join(buttons, '')
    end
end