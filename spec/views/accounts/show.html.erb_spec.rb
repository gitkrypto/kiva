require 'spec_helper'

describe "accounts/show" do
  before(:each) do
    @account = assign(:account, stub_model(Account,
      :native_id => "Native",
      :balance_nqt => "9.99",
      :total_pos_rewards_nqt => "9.99"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Native/)
    rendered.should match(/9.99/)
    rendered.should match(/9.99/)
  end
end
