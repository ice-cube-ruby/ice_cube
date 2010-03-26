module TimeUtil
  
  LeapYearMonthDays	=	[31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
  CommonYearMonthDays	=	[31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

  def self.is_leap?(date)
    (date.year % 4 == 0 && date.year % 100 != 0) || (date.year % 400 == 0)
  end

  def self.days_in_year(date)
    is_leap?(date) ? 366 : 365
  end

  def self.days_in_month(date)
    is_leap?(date) ? LeapYearMonthDays[date.month - 1] : CommonYearMonthDays[date.month - 1]
  end
  
end