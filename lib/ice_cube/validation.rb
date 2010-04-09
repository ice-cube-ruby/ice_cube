module IceCube
  
  class Validation
     
    NUMBER_SUFFIX = ['th', 'st', 'nd', 'rd', 'th', 'th', 'th', 'th', 'th', 'th']
     
    def adjust(goal, date)
      return goal if goal.utc_offset == date.utc_offset
      goal - goal.utc_offset + date.utc_offset
    end
    
    # influences by ActiveSupport's to_sentence
    def sentence(array)
      case array.length
      when 0 ; ''
      when 1 ; array[0].to_s
      when 2 ; "#{array[0]} and #{array[1]}"
      else ; "#{array[0...-1].join(', ')}, and #{array[-1]}"
      end
    end
    
    def nice_numbers(array)
      array.sort!
      sentence array.map { |d| nice_number(d) }
    end
    
    private
    
    def nice_number(number)
      if number == -1
        'last'
      elsif number < -1
        number.abs.to_s << NUMBER_SUFFIX[number.abs % 10] << ' to last'
      else
        number.to_s << NUMBER_SUFFIX[number % 10]  
      end
    end
    
  end
  
end