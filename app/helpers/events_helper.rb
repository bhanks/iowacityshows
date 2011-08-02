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
  
  def price_render(pstr)
    price_arr = pstr.split(",")
    unless(price_arr.first.nil?)
		  if( price_arr.first.casecmp("free") == 0)
  			price = pstr
  		else
  			price = price_arr.map{|a| a.insert(0,'$')}.join(" / ")
  		end
  	else
  	  price = ''
  	end
		price
  end
  
  
end
