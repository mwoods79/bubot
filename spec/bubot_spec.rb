require 'bubot'

module Baz
  def self.buz; end
end

module Foo
  def not_too_slow; end
  def too_slow; sleep 0.006
  end
end

class Qux
  include Foo
  extend Bubot

  watch :not_too_slow, 0.005 do
    Baz.buz
  end

  watch :too_slow, 0.005 do
    Baz.buz
  end
end

describe Bubot do
  describe ".watch" do
    it "calls the strategy(block) when the time exceeds the max time" do
      Baz.should_receive(:buz).once
      Qux.new.too_slow
    end

    it "doesn't call the strategy(block) when the time is less than the max time" do
      Baz.should_not_receive(:buz)
      Qux.new.not_too_slow
    end

    context "order doesn't matter" do

      it "watch is before the method" do
        class Before
          extend Bubot
          watch(:next_method, 0.001) { Baz.buz }
          def next_method; sleep 0.002; end
        end

        Baz.should_receive(:buz).once
        Before.new.next_method
      end

      it "watch is after the method" do
        class After
          extend Bubot
          def previous_method; sleep 0.002; end
          watch(:previous_method, 0.001) { Baz.buz }
        end

        Baz.should_receive(:buz).once
        After.new.previous_method
      end
    end

    context "watching methods that are not defined" do
      it "does nothing and does not break" do
        expect do
          class MethodDoesNotExist
            extend Bubot
            watch(:dont_exist, 0.001) { Baz.buz }
          end
        end.not_to raise_error
      end
    end

    context "do defining new methods" do
      it "passes its instance to the strategy" do
        class RecievesSelfStrategy
          def self.execute(instance)
            # do stuff
          end
        end

        class PassesSelf
          extend Bubot
          watch(:pass_self, 0.001) do |instance|
            RecievesSelfStrategy.execute(instance)
          end
          def pass_self; sleep 0.002; end
        end

        bubot_observed = PassesSelf.new
        RecievesSelfStrategy.should_receive(:execute).with(bubot_observed).once

        bubot_observed.pass_self
      end
    end
  end
end
