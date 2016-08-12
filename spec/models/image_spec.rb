require 'spec_helper'

describe Image do
  describe "for index" do
    before do
      Image.delete_all
    end
    it "should order images by order" do
      @image = FactoryGirl.create(:image, order: 2)
      @image2 = FactoryGirl.create(:image2, order: 1)
      @image3 = FactoryGirl.create(:image3, order: 3)

      Image.for_index.should == [@image2, @image, @image3]
    end

    it "should order images by id if they have no order" do
      @image = FactoryGirl.create(:image)
      @image2 = FactoryGirl.create(:image2)
      @image3 = FactoryGirl.create(:image3)
      Image.for_index.should == [@image, @image2, @image3]
    end

    it "should put images without order at the end" do
      @image = FactoryGirl.create(:image)
      @image2 = FactoryGirl.create(:image2, order: 2)
      @image3 = FactoryGirl.create(:image3, order: 1)
      Image.for_index.should == [@image3, @image2, @image]
    end
  end

  describe "confirm offer" do
    it "should update offer confirmed at" do
      @offer = FactoryGirl.create(:offer)
      Timecop.freeze(2012, 4, 12)
      @image = FactoryGirl.create(:image, offer: @offer)
      @image.confirm_offer
      @offer.confirmed_at.should == Time.current
    end
  end
end
