require 'spec_helper'

describe Session do
  describe "for clean" do
    it "should success" do
      Session.update_all(:updated_at => (Time.now - 2.days))
      Session.clean
      Session.count.should == 0
    end
  end

  
end
