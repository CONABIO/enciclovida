# Manual fix for ActiveSupport logger constant issue
module ActiveSupport
  module LoggerThreadSafeLevel
    Logger = ::Logger
  end
end

# Preload the Logger constant
require 'logger'
