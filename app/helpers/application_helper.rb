module ApplicationHelper
  def show_errors(object, field_name)
    if object.errors.any?
      if !object.errors.messages[field_name].blank?
        object.errors.messages[field_name]
      end
    end
  end

  def format_date_in_japan str
    year_str = t "admin.blog.table.year"
    month_str = t "admin.blog.table.month"
    day_str = t "admin.blog.table.day"
    unless str.nil?
      date = str.to_datetime
      date.strftime "%Y#{year_str}%m#{month_str}%d#{day_str}  %I:%M"
    end
  end
end
