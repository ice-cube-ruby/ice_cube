module SpecialTime
   
  LeapYearMonthDays	=	[31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
  CommonYearMonthDays	=	[31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

  def is_leap?
    (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
  end

  def days_in_year
    is_leap? ? 366 : 365
  end

  def days_in_month
    is_leap? ? LeapYearMonthDays[month - 1] : CommonYearMonthDays[month - 1]
  end

end