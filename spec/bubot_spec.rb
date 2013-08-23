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

    context "timeout is optional" do
      it "timeout is not passed" do
        class NoTimeout
          extend Bubot
          watch(:without_timeout) { Baz.buz }
          def without_timeout() end
        end

        Baz.should_receive(:buz).once
        NoTimeout.new.without_timeout
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

    context "sending messages to strategy" do
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

      it "passes the time it took to the strategy" do
        class RecievesTimeStrategy
          def self.execute(instance, time)
            # do stuff
          end
        end

        class PassesTime
          extend Bubot
          watch(:pass_time, 0.001) do |instance, time|
            RecievesTimeStrategy.execute(instance, time)
          end
          def pass_time; sleep 0.002; end
        end

        bubot_observed = PassesTime.new
        RecievesTimeStrategy.should_receive(:execute) do |instance, time|
          expect(time).to be > 0.002
          expect(instance).to be(bubot_observed)
        end

        bubot_observed.pass_time
      end

      it "passes the returned value form the watched method" do
        class RecievesReturnValueStrategy
          def self.execute(instance, time, original_value)
            # do stuff
          end
        end

        class PassesReturnValue
          extend Bubot
          watch(:pass_return_value, 0.001) do |instance, time, return_value|
            RecievesReturnValueStrategy.execute(instance, time, return_value)
          end
          def pass_return_value
            sleep 0.002
            "return_value"
          end
        end

        bubot_observed = PassesReturnValue.new
        RecievesReturnValueStrategy.should_receive(:execute) do |instance, time, return_value|
          expect(time).to be > 0.002
          expect(instance).to be(bubot_observed)
          expect(return_value).to eq("return_value")
        end

        bubot_observed.pass_return_value
      end
    end

    describe "the original method" do
      it "redefines the method to return the original value" do
        class OriginalMethod
          extend Bubot

          watch :original do
            #something
          end

          def original
            "original value"
          end
        end

        original_class = OriginalMethod.new
        expect(original_class.original).to eql("original value")

      end

    end
  end
end
