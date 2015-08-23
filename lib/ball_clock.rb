#!/usr/bin/env ruby
#
# This is an executable ruby program, to run from the command line:
#
# ruby ball_clock.rb 30
#
#        or
#
# ruby ball_clock.rb 30 325

class BallClock
  def self.run(number_of_balls, number_of_cycles = nil)
    if number_of_cycles == nil 
      self.count_days_till_order_restored(number_of_balls)
    else
      self.print_json_after_cycles(number_of_balls, number_of_cycles)
    end
  end

  def self.count_days_till_order_restored(number_of_balls)
    ball_clock = BallClock.new(number_of_balls)
    initial_ordering = ball_clock.reservoir.ball_queue.dup
    day_count = 0
    is_whole_day = true 
    solution_found = false

    ball_clock.hour_track.set_on_track_dump do
      is_whole_day = !is_whole_day
      if is_whole_day
        day_count += 1
        if initial_ordering == ball_clock.reservoir.ball_queue
          puts "#{number_of_balls} balls cycle after #{day_count} days"
          solution_found = true
        end
      end
    end

    begin
      ball_clock.cycle_next_ball
    end until solution_found
  end

  def self.print_cycles(number_of_balls,number_of_cycles)
    ball_clock = BallClock.new(number_of_balls)
    number_of_cycles.times do
      ball_clock.cycle_next_ball
      puts ball_clock.to_json
    end
  end
  
  def self.print_json_after_cycles(number_of_balls, number_of_cycles)
    ball_clock = BallClock.new(number_of_balls)
    number_of_cycles.times do
      ball_clock.cycle_next_ball
    end
      puts ball_clock.to_json
  end

  attr_reader :reservoir
  attr_accessor :hour_track

  def initialize(ball_count = 30)
    @ball_count = ball_count

    setup_tracks
    fill_reservoir
  end

  def setup_tracks
    @reservoir = BallTrack.new(nil, "Main", @ball_count)
    @hour_track = BallTrack.new(@reservoir, "Hour", 11, @reservoir, true)
    @five_minute_track = BallTrack.new(@reservoir, "FiveMin", 11, @hour_track)
    @minute_track = BallTrack.new(@reservoir, "Min", 4, @five_minute_track)
  end

  def reset_clock(new_number_of_balls = @ball_count)
    @ball_count = new_number_of_balls
    clear_balls
    fill_reservoir
  end

  def cycle_next_ball()
    next_ball = @reservoir.get_ball
    @minute_track.add_ball(next_ball)
  end

  def get_min
    @minute_track.count_balls
  end

  def get_fivemin
    @five_minute_track.count_balls
  end

  def get_hour
    @hour_track.count_balls
  end

  def fill_reservoir
    (1..@ball_count).to_a.each { |ball_number| @reservoir.add_ball Ball.new(ball_number) }
  end

  def to_json
    result = ""
    result = [@minute_track, @five_minute_track, @hour_track, @reservoir].map do |track|
      track.to_json
    end
    "{" + result.join(",") + "}"
  end
end

class BallTrack
  attr_reader :ball_queue, :name

  def initialize(reservoir, name, track_size = 10000, next_track = nil, constant_ball = false)
    @reservoir = reservoir 
    @name = name
    @constant_ball = constant_ball
    @track_size = track_size
    @ball_queue = []
    @next_track = next_track || reservoir
    @on_track_dump = Proc.new{ || }
  end

  def add_ball(next_ball)
    if is_the_reservoir?
      # ProTip: Array#unshift pushes onto the beginning of the array
      @ball_queue.unshift(next_ball)     
    else
      if is_track_full?
          dump_track
          @next_track.add_ball(next_ball)
          @on_track_dump.call
      else
        @ball_queue << next_ball
      end
    end
  end

  def is_the_reservoir?
    @next_track == nil
  end

  def get_ball
    @ball_queue.pop
  end

  def is_track_full?
    @ball_queue.count >= @track_size
  end

  def dump_track
    @ball_queue.reverse.each do |ball|
      @reservoir.add_ball(ball)
    end

    @ball_queue = []
  end

  def count_balls
    @ball_queue.count + (@constant_ball?1:0)
  end

  def set_on_track_dump(&track_dump_callback)
    @on_track_dump = track_dump_callback
  end

  def to_json
    # Hotfix for reversed main in JSON
    if is_the_reservoir?
      "\"#{@name}\":#{ball_ids.reverse.to_s.delete(" ")}"
    else
      "\"#{@name}\":#{ball_ids.to_s.delete(" ")}"
    end
  end

  def ball_ids
    @ball_queue.map {|ball| ball.id }
  end
end

class Ball
  attr_accessor :id
  def initialize(id)
    @id = id
  end

end


if ARGV.length >= 2
  BallClock.run(ARGV[0].to_i, ARGV[1].to_i)
elsif ARGV.length == 1
  BallClock.run(ARGV[0].to_i)
else
  puts "USAGE:\n\tball_clock {NumberOfBalls} {NumberOfCycles}\nExample:\n\tball_clock 30\n30 balls cycle after 15 days."
end

