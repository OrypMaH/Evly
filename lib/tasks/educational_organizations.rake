namespace :educational_organizations do
  desc "Создание организации по умолчанию и связывание с мероприятиями"
  task setup_default: :environment do
    puts "=== Настройка образовательных организаций ==="
    
    # Параметры организации по умолчанию
    default_org_params = {
      name: "ФГБОУ ВО «Амурский государственный университет»",
      federal_district: "Дальневосточный",
      federal_subject: "Амурская область"
    }
    
    # 1. Создаем или находим организацию по умолчанию
    default_org = EducationalOrganization.find_or_create_by!(name: default_org_params[:name]) do |org|
      org.federal_district = default_org_params[:federal_district]
      org.federal_subject = default_org_params[:federal_subject]
    end
    
    if default_org.persisted?
      puts "✅ Организация по умолчанию:"
      puts "   Название: #{default_org.name}"
      puts "   Округ: #{default_org.federal_district}"
      puts "   Субъект: #{default_org.federal_subject}"
    else
      puts "❌ Ошибка создания организации: #{default_org.errors.full_messages.join(', ')}"
      exit 1
    end
    
    # 2. Связываем все мероприятия без организации с организацией по умолчанию
    events_without_org = Event.where(educational_organization_id: nil)
    
    if events_without_org.any?
      updated_count = events_without_org.update_all(educational_organization_id: default_org.id)
      puts "\n✅ Связано #{updated_count} мероприятий с организацией по умолчанию"
    else
      puts "\nℹ️ Все мероприятия уже имеют организацию"
    end
    
    # 4. Статистика
    puts "\n=== Статистика ==="
    puts "Всего организаций: #{EducationalOrganization.count}"
    puts "Всего мероприятий: #{Event.count}"
    puts "Мероприятий с организацией: #{Event.where.not(educational_organization_id: nil).count}"
    puts "Мероприятий без организации: #{Event.where(educational_organization_id: nil).count}"
    
    puts "\n=== Задача выполнена ==="
  end
  
end