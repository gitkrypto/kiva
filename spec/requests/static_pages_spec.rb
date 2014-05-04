require 'spec_helper'

describe "Static pages" do

  describe "Home page" do

    it "should have the content 'Blockexplorer'" do
      visit '/static_pages/home'
      expect(page).to have_content('Blockexplorer')
    end

    it "should have the right title" do
      visit '/static_pages/home'
      expect(page).to have_title("FIMKrypto Blockexplorer")
    end

  end
end
