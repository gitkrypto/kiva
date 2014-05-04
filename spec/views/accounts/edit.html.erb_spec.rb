require 'spec_helper'

describe "accounts/edit" do
  before(:each) do
    @account = assign(:account, stub_model(Account,
      :native_id => "MyString",
      :balance_nqt => "9.99",
      :total_pos_rewards_nqt => "9.99"
    ))
  end

  it "renders the edit account form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", account_path(@account), "post" do
      assert_select "input#account_native_id[name=?]", "account[native_id]"
      assert_select "input#account_balance_nqt[name=?]", "account[balance_nqt]"
      assert_select "input#account_total_pos_rewards_nqt[name=?]", "account[total_pos_rewards_nqt]"
    end
  end
end
