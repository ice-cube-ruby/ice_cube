module IceCube
  
  class Validation
     
    NUMBER_SUFFIX = ['th', 'st', 'nd', 'rd', 'th', 'th', 'th', 'th', 'th', 'th']
    SPECIAL_SUFFIX = { 11 => 'th', 12 => 'th', 13 => 'th', 14 => 'th' } 
    
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
        suffix = SPECIAL_SUFFIX.include?(number) ? SPECIAL_SUFFIX[number] : NUMBER_SUFFIX[number.abs % 10]
        number.abs.to_s << suffix << ' to last'
      else
        suffix = SPECIAL_SUFFIX.include?(number) ? SPECIAL_SUFFIX[number] : NUMBER_SUFFIX[number.abs % 10]
        number.to_s << suffix  
      end
    end
    
  end
  
end
