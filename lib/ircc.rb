# frozen_string_literal: true

require_relative "ircc/version"
require_relative "ircc/connection"
require_relative "ircc/command"
require_relative "ircc/client"

module Ircc
  class Error < StandardError; end
end
