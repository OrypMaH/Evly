# app/helpers/links_helper.rb
module LinksHelper
  # Универсальная ссылка с наследованием стилей
  def smart_link_to(resource, text = nil, options = {})
    text ||=   resource.respond_to?(:name) ? resource.name : 
               resource.respond_to?(:title) ? resource.title : 
               resource.respond_to?(:full_name) ? resource.full_name :
               resource.to_s
    
    css_class = [options[:class], 'smart-link'].compact.join(' ')
    options = options.merge(class: css_class)
    link_to(text, resource, options)
  end
  
  def link_to_user(user, options = {})
    text = user.full_name
    smart_link_to(user, text, options)
  end
  def link_to_short_user(user, options = {})
    text = user.short_name
    smart_link_to(user, text, options)
  end
  
  def link_to_event(event, options = {})
    text = event.title
    smart_link_to(event, text, options)
  end
  
  def link_to_department(department, options = {})
    text = department.name
    smart_link_to(department, text, options)
  end
  
  def link_to_plan(plan, options = {})
    text = plan.title
    smart_link_to(plan, text, options)
  end
  def link_to_direction(direction,text=nil, options = {})
    text ||= direction.name
    smart_link_to(department_direction_path(direction.department,direction), text, options)
  end
end