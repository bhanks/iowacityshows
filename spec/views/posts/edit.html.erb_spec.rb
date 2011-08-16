require 'spec_helper'

describe "posts/edit.html.erb" do
  before(:each) do
    @post = assign(:post, stub_model(Post,
      :url => "MyString",
      :block => "MyText",
      :venue_id => 1
    ))
  end

  it "renders the edit post form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => posts_path(@post), :method => "post" do
      assert_select "input#post_url", :name => "post[url]"
      assert_select "textarea#post_block", :name => "post[block]"
      assert_select "input#post_venue_id", :name => "post[venue_id]"
    end
  end
end
