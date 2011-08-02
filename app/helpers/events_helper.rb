module EventsHelper
  
  def test
    "what"
  end
  
  def event_day(event_date)
    if(event_date.month == Date.today.month && event_date.mday == Date.today.mday)
      str = "Today"
    else
      str = event_date.strftime("%a")
    end
    str
  end
  
end
