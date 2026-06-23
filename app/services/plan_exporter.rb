# app/services/excel_export/plan_exporter.rb
  class PlanExporter
    attr_reader :plan, :event_departments
    
    def initialize(plan)
      @plan = plan
      @event_departments = plan.event_departments
                                  .includes(event: [:direction, :level, :educational_organization, 
                                                  responsible_people: [:user, :role]])
                                  .order('events.start_date')
    end
    
    def generate
      package = Axlsx::Package.new
      workbook = package.workbook
      
      # Добавляем стили
      styles = define_styles(workbook)
      
      # Основной лист с мероприятиями
      add_main_sheet(workbook, styles)
      
      package
    end
    
    private
    
    def define_styles(workbook)
      {
        # Стиль для заголовков таблицы
        header: workbook.styles.add_style(
          b: true,
          alignment: { horizontal: :center, vertical: :center, wrap_text: true },
          bg_color: "F0F0F0",
          border: { style: :thin, color: "000000" }
        ),
        
        # Стиль для подзаголовков (вторая строка заголовка для ответственных лиц)
        subheader: workbook.styles.add_style(
          b: true,
          alignment: { horizontal: :center, vertical: :center, wrap_text: true },
          bg_color: "FAFAFA",
          border: { style: :thin, color: "000000" }
        ),
        
        # Стиль для обычных ячеек с переносом и АВТОПОДБОРОМ ВЫСОТЫ
        cell_wrap: workbook.styles.add_style(
          alignment: { vertical: :top, wrap_text: true },
          border: { style: :thin, color: "000000" }
        ),
        
        # Стиль для дат с переносом
        date_wrap: workbook.styles.add_style(
          format_code: "dd.mm.yyyy",
          alignment: { vertical: :top, wrap_text: true },
          border: { style: :thin, color: "000000" }
        ),
        
        # Стиль для чисел с переносом
        number_wrap: workbook.styles.add_style(
          format_code: "#,##0",
          alignment: { vertical: :top, wrap_text: true },
          border: { style: :thin, color: "000000" }
        )
      }
    end
    
    def add_main_sheet(workbook, styles)
      workbook.add_worksheet(name: "План мероприятий") do |sheet|
        # ВКЛЮЧАЕМ АВТОПОДБОР ВЫСОТЫ ДЛЯ ВСЕГО ЛИСТА
        sheet.sheet_view do |sv|
          sv.show_grid_lines = true
        end
        
        # Создаем сложный заголовок таблицы
        create_table_header(sheet, styles)
        
        # Заполняем данными
        fill_table_data(sheet, styles)
        
        # Настраиваем ширину колонок
        sheet.column_widths 3,      # №
                           15,     # Федеральный округ
                           10,     # Субъект РФ
                           15,     # Наименование ООВО
                           18,     # Направление
                           40,     # Название мероприятия
                           15,     # Уровень
                           15,     # Формат
                           20,     # Дата/период
                           15,     # Место проведения
                           15,     # Фактический охват
                           15,     # ФИО ответственных лиц
                           15,     # Должность
                           20      # Контактные данные
        
        # ПРИМЕНЯЕМ АВТОПОДБОР ВЫСОТЫ КО ВСЕМ СТРОКАМ
        sheet.rows.each do |row|
          row.height = nil  # nil означает "автоподбор"
        end
      end
    end
    
    def create_table_header(sheet, styles)
      # ПЕРВАЯ СТРОКА ЗАГОЛОВКА
      first_row = sheet.add_row [
        "№",
        "Федеральный округ РФ",
        "Субъект РФ",
        "Наименование ООВО",
        "Направление воспитательной работы",
        "Название мероприятия",
        "Уровень мероприятия",
        "Формат мероприятия",
        "Дата/период проведения",
        "Место проведения мероприятия",
        "Фактический охват количества участников",
        "Ответственное лицо ООВО за проведение мероприятия",
        "", # пустая для объединения
        ""  # пустая для объединения
      ], style: styles[:header]
      
      # ВТОРАЯ СТРОКА ЗАГОЛОВКА
      second_row = sheet.add_row [
        "",  # №
        "",  # Федеральный округ
        "",  # Субъект РФ
        "",  # Наименование ООВО
        "",  # Направление
        "",  # Название мероприятия
        "",  # Уровень
        "",  # Формат
        "",  # Дата/период
        "",  # Место проведения
        "",  # Фактический охват
        "ФИО",           # подколонка 1
        "Должность",     # подколонка 2
        "Контактные данные" # подколонка 3
      ], style: styles[:subheader]
      
      # Объединяем ячейки для основных колонок по вертикали
      ("A".."K").each do |col|
        sheet.merge_cells("#{col}1:#{col}2")
      end
      
      # Объединяем ячейки для "Ответственное лицо" по горизонтали
      sheet.merge_cells("L1:N1")
      
      # Устанавливаем фиксированную высоту для заголовков
      first_row.height = 30
      second_row.height = 25
    end
    
    def fill_table_data(sheet, styles)
      event_departments.each_with_index do |event_department, index|
        event = event_department.event
        educational_organization = event.educational_organization
        direction = event.direction
        level = event.level
        responsible_people = event.responsible_people.to_a
        
        # Формируем строки с данными всех ответственных лиц
        responsible_names = []
        responsible_roles = []
        responsible_contacts = []
        
        responsible_people.each do |rp|
          responsible_names << rp.user.full_name
          responsible_roles << rp.role.name
          responsible_contacts << (rp.user.contact.presence || "Не указаны")
        end
        
        # Базовая строка с основными данными
        row = [
          index + 1,
          educational_organization&.federal_district || "Не указан",
          educational_organization&.federal_subject || "Не указан",
          educational_organization&.name || "Не указана",
          direction&.name || "Не указано",
          event.title,
          level&.name || "Не указан",
          event.format || "Не указан",
          format_event_period(event.start_date, event.end_date),
          event.location || "Не указано",
          event.people || 0,
          responsible_names.join(",\n"),
          responsible_roles.join(",\n"),
          responsible_contacts.join(",\n")
        ]
        
        # Добавляем строку в таблицу
        data_row = sheet.add_row row do |r|
          r.cells.each_with_index do |cell, idx|
            case idx
            when 0  # №
              cell.style = styles[:cell_wrap]
            when 1, 2, 3, 4, 5, 6, 7, 9  # Текстовые поля
              cell.style = styles[:cell_wrap]
            when 8  # Дата
              cell.style = styles[:date_wrap]
            when 10  # Количество участников
              cell.style = styles[:number_wrap]
            when 11, 12, 13  # Ответственные лица
              cell.style = styles[:cell_wrap]
            end
          end
        end
        
        # ВАЖНО: Устанавливаем height = nil для автоподбора высоты
        data_row.height = nil
      end
    end
    
    def format_event_period(start_date, end_date)
      return "Даты не указаны" unless start_date
      
      if end_date && start_date != end_date
        "#{start_date.strftime('%d.%m.%Y')} - #{end_date.strftime('%d.%m.%Y')}"
      else
        start_date.strftime('%d.%m.%Y')
      end
    end
  end