module CurrentDepartmentRedirect
  extend ActiveSupport::Concern
  
  def redirect_with_proper_department(fallback: root_path)
    referer = request.referer
    
    return fallback unless referer && current_user.current_department.present?
    
    begin
      # Парсим URL чтобы получить путь и query параметры отдельно
      uri = URI.parse(referer)
      
      # Получаем параметры из пути через Rails router
      route_params = Rails.application.routes.recognize_path(uri.path)
      puts "CONTROLLER: #{route_params[:controller]}"
      # Получаем query параметры
      query_params = uri.query ? Rack::Utils.parse_query(uri.query) : {}
      
      # Проверяем, нужен ли department_id для этого маршрута
      if route_requires_department?(route_params)
        # Обновляем department_id в route_params (для пути)
        route_params[:department_id] = current_user.current_department.id
        
        # Объединяем все параметры
        all_params = route_params.merge(query_params)
        
        # Генерируем новый путь с сохранением query параметров
        url_for(all_params.merge(only_path: true))
      else
        # Возвращаем оригинальный реферер
        referer
      end
      
    rescue URI::InvalidURIError, ActionController::RoutingError
      # Если не смогли распознать путь
      referer
    end
  end
  
  private
  
  def route_requires_department?(route_params)
    department_dependent_routes = [
      {controller: 'department_resources/events', action: 'index'},
      {controller: 'department_resources/plans', action: 'index'},
      {controller: 'department_resources/roles', action: 'index'},
      {controller: 'department_resources/users', action: 'index'},
      {controller: 'department_resources/directions', action: 'index'}
    ]
    
    department_dependent_routes.any? do |route|
      route[:controller] == route_params[:controller] && 
      route[:action] == route_params[:action]
    end
  end
end