require 'spec_helper'

describe Video do
  describe "for index" do
    it "should order videos by order" do
      @offer = FactoryGirl.create(:offer)
      @video = FactoryGirl.create(:video, order: 2)
      @video2 = FactoryGirl.create(:video2, order: 1)
      @video3 = FactoryGirl.create(:video3, order: 3)
      Video.for_index.should == [@video2, @video, @video3]
    end

    it "should order videos by id if they have no order" do
      @video = FactoryGirl.create(:video, order: 1)
      @video2 = FactoryGirl.create(:video2, order: 2)
      @video3 = FactoryGirl.create(:video3, order: 3)
      Video.for_index.should == [@video, @video2, @video3]
    end

    it "should put videos wihout order at the end" do
      Video.delete_all
      @video = FactoryGirl.create(:video)
      @video2 = FactoryGirl.create(:video2)
      @video3 = FactoryGirl.create(:video3)
      Video.for_index.should == [@video, @video2, @video3]
    end
  end

  describe "confirm offer" do
    it "should update offer confirmed at" do
      @offer = FactoryGirl.create(:offer)
      Timecop.freeze(2012, 4, 12)
      @video = FactoryGirl.create(:video, offer: @offer)
      @video.confirm_offer
      @offer.confirmed_at.should == Time.current
    end
  end

  describe "extract_youtube_id" do
    it "should handle youtube.com urls" do
      Video.extract_youtube_id("http://www.youtube.com/watch?v=FED5pfAEzvk&feature=blub").should == "FED5pfAEzvk"
    end

    it "should handle youtu.be urls" do
      Video.extract_youtube_id("http://youtu.be/FED5pfAEzvk").should == "FED5pfAEzvk"
    end

    it "should handle raw ids" do
      Video.extract_youtube_id("FED5pfAEzvk").should == "FED5pfAEzvk"
    end

    it "should reset invalid an input" do
      Video.extract_youtube_id("invalid").should == nil
    end
  end
end