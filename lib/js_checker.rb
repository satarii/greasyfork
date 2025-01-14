require 'mini_racer'

class JsChecker
  attr_accessor :result
  def initialize(js)
    @js = js
  end

  def check
    begin
      context = MiniRacer::Context.new(timeout: 500, max_memory: 200000000)
      # Enclose in a function - we just want to check for syntax errors, not execute. Also some code does a top-level
      # return.
      context.eval("function foo() {\n#{@js}\n}")
      self.result = nil
    rescue MiniRacer::ParseError => e
      message = e.message
      #parse_error_match = /at undefined:([0-9]+):([0-9]+)/.match(message)
      #message = message.gsub(parse_error_match[0], "at line #{parse_error_match[1].to_i + 6}, col #{parse_error_match[2]}") if parse_error_match
      self.result = message
    rescue MiniRacer::RuntimeError
      # Some other error. Since we don't support all the browser objects, we'll let this go.
      self.result = nil
    end
    self.result == nil
  end

  def errors
    return [] if result == nil
    [[:syntax, result]]
  end
end