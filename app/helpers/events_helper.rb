module EventsHelper
  
  def am_pm(time)
    str = (time.hour > 12)? "#{time.hour % 12} PM": "#{time.hour % 12} AM"
  end
  
  def event_day(event_date)
    if(event_date.month == Date.today.month && event_date.mday == Date.today.mday)
      str = "Today"
    else
      str = event_date.strftime("%a")
    end
    str
  end
  
  def event_day_indiv(event_date)
    if(event_date.month == Date.today.month && event_date.mday == Date.today.mday)
      str = "Today"
    else
      str = event_date.strftime("%a")
    end
    str
  end
  
  def short_price(prices)
    arr = []
    prices.each do |price|
      arr << price.amount
    end
    price = arr.join(" / ")
  end
  
  
end
