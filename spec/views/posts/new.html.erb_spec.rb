require 'spec_helper'

describe "posts/new.html.erb" do
  before(:each) do
    assign(:post, stub_model(Post,
      :url => "MyString",
      :block => "MyText",
      :venue_id => 1
    ).as_new_record)
  end

  it "renders new post form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => posts_path, :method => "post" do
      assert_select "input#post_url", :name => "post[url]"
      assert_select "textarea#post_block", :name => "post[block]"
      assert_select "input#post_venue_id", :name => "post[venue_id]"
    end
  end
end
