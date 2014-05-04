module ApplicationHelper
  
  # Returns the full title on a per-page basis.
  def full_title(page_title)
    base_title = "FIM"
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end
  
  # Converts a NXT timestamp to a date string
  def convert_timestamp(timestamp)
  Time.at(DateTime.new(2013, 10, 24, 12, 0, 0, 0).to_time.to_i + timestamp).to_formatted_s(:long) rescue '-'
  end
  
  # Converts NQT to NXT for display purposes
  def convert_to_nxt(amount)
    amount          = amount.to_i
    negative        = ""
    afterComma      = ""
    fractionalPart  = (amount % 100000000).to_s
    amount          = amount / 100000000
    if amount < 0 
      amount        = amount.abs
      negative      = "-"
    end    
    if fractionalPart != "0"
      afterComma = ".";
      for i in (fractionalPart.length..7)
        afterComma += "0";
      end
      afterComma += fractionalPart.sub(/0+$/,'')
    end  
    "#{negative}#{amount}#{afterComma}"
  end
  #convert_to_nxt 1
end
