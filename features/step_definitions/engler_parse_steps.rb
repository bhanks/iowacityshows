Given /^I have a page to scrape twice$/ do
  index = Nokogiri::HTML(open('http://www.englert.org/events.php?view=upcoming')).css('#block_interior1').css("a").first
  @loc = index.attributes["href"].value
  p @loc
end

When /^I pull the block out of those pages$/ do
  @block1 = Nokogiri::HTML(open('http://www.englert.org/'+@loc)).css("#content_interior")
  @block2 = Nokogiri::HTML(open('http://www.englert.org/'+@loc)).css("#content_interior")
  
end

Then /^I should have the same block$/ do
  @block1.inner_html.should == @block2.inner_html
end

