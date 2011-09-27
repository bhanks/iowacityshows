Given /^I scrape the englert events$/ do
  Post.delete_all
  @venue = Venue.find_by_name("The Englert")
  
  posts = Post::Englert.gather(@venue)
  p "Post count: #{posts.count}"
end

When /^I scrape them again$/ do
  new_posts = Post::Englert.gather(@venue)
  p "Post count: #{new_posts.count}"
  @post_count = new_posts.count
end

Then /^I should have no new events$/ do
  @post_count.should == 0
end
