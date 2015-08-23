require 'spec_helper'
require './lib/ball_clock.rb'

describe ::Ball do
  subject { described_class.new }
  let(:second_ball) { described_class.new }

  it "has different values" do
    expect(subject.id).to_not be(second_ball.id)
  end
end

describe ::BallTrack do
  context "when top track overfills" do
    let(:reservoir_track) { described_class.new(nil, "reservoir") }
    let(:bottom_track){ described_class.new(reservoir_track, "bottom", 3) }
    let(:top_track) { described_class.new(reservoir_track, "top", 1, bottom_track) }

    it "should dump track on second ball" do
      top_track.add_ball(Ball.new)
      expect(top_track.count_balls).to be(1)
      top_track.add_ball(Ball.new)
      expect(top_track.count_balls).to be(0)
      expect(bottom_track.count_balls).to be(1)
      expect(reservoir_track.count_balls).to be(1)
    end
  end

  context "when top track overfills" do
    let(:reservoir_track) { described_class.new(nil, "reservoir") }
    let(:bottom_track){ described_class.new(reservoir_track, "bottom", 3) }
    let(:top_track) { described_class.new(reservoir_track, "top", 2, bottom_track) }

   it "should reverse the order of the balls in the reservoir rack, then add on last ball" do
      top_track.add_ball(Ball.new(0))
      top_track.add_ball(Ball.new(1))
      expect(top_track.ball_ids).to eq([0,1])
      top_track.add_ball(Ball.new(2))
      expect(reservoir_track.ball_ids).to eq([1,0])
      expect(bottom_track.ball_ids).to eq([2])
    end
  end
end

describe ::BallClock do
  describe "When first created" do
    let(:number_of_balls) { 3 }
    subject { described_class.new(number_of_balls) }

    it "should contain all the balls" do
      expect(subject.reservoir.count_balls).to eq(number_of_balls)
    end

    it "should generate blank JSON" do
      expect(subject.to_json).to eq('{"Min":[],"FiveMin":[],"Hour":[],"Main":[1,2,3]}')
    end
  end
  describe "when running" do
    let(:number_of_balls) { 30 }
    subject { described_class.new(number_of_balls) }
    it "should say 2 hour, 1 fivemin, and 1 min after 66 cycles" do
      66.times { subject.cycle_next_ball }
      expect(subject.get_hour).to eq(2)
      expect(subject.get_fivemin).to eq(1)
      expect(subject.get_min).to eq(1)
    end
  end
end
