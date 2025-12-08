module EventsHelper
    def participating_count(department)
      Event.participating_by(department).count
  end

  def offered_count(department)
      Event.offered_to(department).count
  end

  def my_events_count
      current_user.events.count
  end

  def event_department_for(event, department)
      approved_ed = ApprovedEventDepartment.find_by(event: event, department: department)
      return approved_ed if approved_ed
      
      OfferedEventDepartment.find_by(event: event, department: department)
  end

  def render_event_status(event, department)
    status = event.status_for(department)
    
    case status
    when 'offered'
      content_tag(:span, 'Ожидает ответа', class: 'ui yellow label')
    when 'approved'
      ed = ApprovedEventDepartment.find_by(event: event, department: department)
      participants_text = ed ? " (#{ed.participants_count} чел.)" : ""
      content_tag(:span, "Участвует#{participants_text}", class: 'ui green label')
    else
      content_tag(:span, 'Не участвует', class: 'ui grey label')
    end
  end
  def render_event_buttons(event_related_object)
    buttons = []
    case event_related_object.class.name
    when 'Event'
      get_event_actions(event_related_object,buttons)
    when 'OfferedEventDepartment'
      get_offered_event_actions(event_related_object,buttons)
    when 'ApprovedEventDepartment'
      get_approved_event_actions(event_related_object,buttons)
    end
      
    safe_join(buttons, '')
  end

  def get_event_actions(event,buttons)
    
    get_basic_event_actions(event,buttons)
    # Кнопка редактирования
    if can?(:edit, event)
      buttons << link_to(edit_event_path(event), 
                    class: 'ui icon button', 
                    title: 'Редактировать') do
        content_tag(:i, '', class: 'edit icon')
      end
    end
    
    buttons << button_tag(
      content_tag(:i, '', class: 'hand paper icon'),
      class: 'ui icon blue button offer-button',
      title: 'Предложить участие',
      data: {
        'event-id': event.id,
        'event-title': event.title,
        'toggle': 'modal',
        'target': '#offerParticipationModal'
      }
    )
    # Кнопка удаления мероприятия
    if can?(:delete, event)
      buttons << link_to(event_path(event), 
                    method: :delete,
                    class: 'ui icon negative button',
                    title: 'Удалить',
                    data: { confirm: "Удалить мероприятие '#{event.title}'? Это действие нельзя отменить." }) do
        content_tag(:i, '', class: 'trash icon')
      end
    end
  end
  
  def get_basic_event_actions(event,buttons)
  # Кнопка просмотра
    buttons << link_to(event_path(event), 
                  class: 'ui icon button', 
                  title: 'Просмотреть') do
      content_tag(:i, '', class: 'eye icon')
    end
  end

  def get_offered_event_actions(event_department,buttons)
    get_basic_event_actions(event_department.event,buttons)
    if can?(:approve, event_department)
      buttons << button_tag(
          content_tag(:i, '', class: 'check icon'),
          class: 'ui icon green button approve-button',
          title: 'Утвердить участие',
          data: {
            'event-department-id': event_department.id,
            'event-title': event_department.event.title,
            'toggle': 'modal',
            'target': '#approveParticipationModal'
          }
      )
    end
    # Кнопка отклонения для предложенного участия
    if can?(:reject, event_department)
      buttons << link_to(reject_offered_event_department_path(event_department), 
                      method: :patch, 
                      class: 'ui icon red button',
                      title: 'Отклонить участие',
                      data: { confirm: "Отклонить участие в мероприятии '#{event_department.event.title}'?" }) do
          content_tag(:i, '', class: 'times icon')
      end
    end
  end

  def get_approved_event_actions(event_department,buttons)
    get_basic_event_actions(event_department.event,buttons)
    if can?(:approve, event_department)
      buttons << button_tag(
          content_tag(:i, '', class: 'edit icon'),
          class: 'ui icon yellow button edit-participation-button',
          title: 'Уточнить участие',
          data: {
            'event-department-id': event_department.id,
            'event-title': event_department.event.title,
            'participants-count': event_department.participants_count,
            'toggle': 'modal',
            'target': '#editParticipationModal'
          }
      )
    end
    # Кнопка отмены для утвержденного участия
    if can?(:reject, event_department)
      buttons << link_to(reject_approved_event_department_path(event_department), 
                      method: :patch, 
                      class: 'ui icon red button',
                      title: 'Отменить участие',
                      data: { confirm: "Отменить участие в мероприятии '#{event_department.event.title}'? Это действие нельзя отменить." }) do
          content_tag(:i, '', class: 'times icon')
      end
    end
  end
  # app/helpers/events_helper.rb
  def empty_table_message
    case @active_tab
    when 'approved'
      "Нет мероприятий с участием вашего подразделения"
    when 'offered'
      "Нет предложенных мероприятий"
    when 'my_events'
      "Вы еще не создали мероприятий"
    else
      "Мероприятия не найдены"
    end
  end

  def render_table_for_tab
    case @active_tab
    when 'approved'
      render partial: 'participating_table', locals: { event_departments: @event_departments }
    when 'offered'
      render partial: 'offered_table', locals: { event_departments: @event_departments }
    when 'my_events'
      render partial: 'my_events_table', locals: { events: @events }
    else
      render partial: 'all_events_table', locals: { events: @events }
    end
  end

end