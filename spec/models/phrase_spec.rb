require 'spec_helper'

describe Phrase do
  describe "ordered" do
    before do
      Phrase.delete_all
    end
    it "should order correctly" do
      @admin_phrase = FactoryGirl.create(:admin_phrase)
      @phrase = FactoryGirl.create(:phrase)
      Phrase.ordered.should == [@admin_phrase, @phrase]
    end
  end
end
