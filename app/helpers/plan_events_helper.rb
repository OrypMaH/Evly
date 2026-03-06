# app/helpers/plan_events_helper.rb
module PlanEventsHelper
  # Рендерим кнопки действий для мероприятия в плане
  def render_plan_event_actions(plan_event)
    buttons = []
    
    # Кнопка просмотра мероприятия
    buttons << link_to([plan_event.event_department.event], 
                class: 'ui icon button',    
                title: 'Просмотреть мероприятие') do
      content_tag(:i, '', class: 'eye icon')
    end
    
    # Кнопка удаления из плана (если есть права)
    if can?(:remove_event, plan_event.plan.department)
      buttons << link_to(plan_event_path(plan_event),
                method: :delete,
                class: 'ui icon negative button',
                title: 'Удалить из плана',
                data: { 
                  confirm: "Удалить мероприятие '#{plan_event.event_department.event.title}' из плана?" 
                }) do
        content_tag(:i, '', class: 'trash icon')
      end
    end
    
    safe_join(buttons, '')
  end
  
  # Рендерим статус мероприятия в плане
  def render_plan_event_status(plan_event)
    event = plan_event.event_department.event
    ed = plan_event.event_department
    
    status_badge = case ed.status
    when 'approved'
      content_tag(:span, 'Утверждено', class: 'ui green horizontal label')
    when 'offered'
      content_tag(:span, 'Предложено', class: 'ui yellow horizontal label')
    else
      content_tag(:span, 'Неизвестно', class: 'ui grey horizontal label')
    end
    
    period_badge = if event.ongoing?
      content_tag(:span, 'Идет сейчас', class: 'ui red horizontal label')
    elsif event.upcoming?
      content_tag(:span, 'Скоро', class: 'ui blue horizontal label')
    else
      content_tag(:span, 'Завершено', class: 'ui grey horizontal label')
    end
    
    safe_join([status_badge, period_badge], ' ')
  end
  
  # Рендерим информацию о мероприятии для таблицы
  def render_plan_event_info(plan_event)
    event = plan_event.event_department.event
    ed = plan_event.event_department
    
    content_tag(:div, class: 'ui list') do
      concat(content_tag(:div, class: 'item') do
        concat(content_tag(:i, '', class: 'users icon'))
        concat(content_tag(:div, class: 'content') do
          concat(content_tag(:div, class: 'header') do
            "Участников: #{ed.participants_count}"
          end)
        end)
      end)
      
      concat(content_tag(:div, class: 'item') do
        concat(content_tag(:i, '', class: 'calendar icon'))
        concat(content_tag(:div, class: 'content') do
          content_tag(:div, event.period_text, class: 'description')
        end)
      end)
    end
  end
end