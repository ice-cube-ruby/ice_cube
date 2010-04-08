module IceCube
  
  class Validation
     
    NUMBER_SUFFIX = ['th', 'st', 'nd', 'rd', 'th', 'th', 'th', 'th', 'th', 'th']
     
    def adjust(goal, date)
      return goal if goal.utc_offset == date.utc_offset
      goal - goal.utc_offset + date.utc_offset
    end
    
    def nice_numbers(array)
      array.map { |num| nice_number(num) }.join(', ')
    end
    
    private
    
    def nice_number(number)
      if number < 0
        number.abs.to_s << NUMBER_SUFFIX[number.abs % 10] << ' to last'
      else
        number.to_s << NUMBER_SUFFIX[number % 10]  
      end
    end
    
  end
  
end