module Huoqiang

  # Provide a logger
  #
  # @param [String] file_name Name of the log file
  def self.logger(file_name)
    @logger ||= Logger.new(File.join(File.expand_path(File.dirname(__FILE__)),"../log/#{file_name}.log"))
  end
end

# Monkey patching add so that we have the Class name from where
# the logger is executed. This hack assume that the file name
# containing the class is indentical to the class name as the
# Ruby convention suggests
#
# Second Monkey patch is the ability to send per email what's
# being logged.
class Logger
  # @param [Boolean] to_email Shall we send that log by email as well
  def add(severity, message = nil, progname = nil, to_email = false, &block)
    severity ||= UNKNOWN
    if @logdev.nil? or severity < @level
      return true
    end
    progname ||= @progname
    if message.nil?
      if block_given?
        message = yield
      else
        message = progname
        progname = @progname
      end
    end

    # Monkey patching
    message = "[#{caller[1].split(':')[0].split('/')[-1].gsub('.rb','').capitalize}]" + message.to_s

    if to_email
      email = Skynet::Email.new()
      email.send(format_severity(severity), message)
    end
    # End Monkey patching
    @logdev.write(
      format_message(format_severity(severity), Time.now, progname, message))
    true
  end
  alias log add

  # Monkey patching
  # For the methods below we added the to_email param
  def info(progname = nil, to_email = false, &block)
    add(INFO, nil, progname, to_email, &block)
  end

  def warn(progname = nil, to_email = false, &block)
    add(WARN, nil, progname, to_email, &block)
  end

  def error(progname = nil, to_email = false, &block)
    add(ERROR, nil, progname, to_email, &block)
  end

  def fatal(progname = nil, to_email = false, &block)
    add(FATAL, nil, progname, to_email, &block)
  end

  def unknown(progname = nil, to_email = false, &block)
    add(UNKNOWN, nil, progname, to_email, &block)
  end

  def debug(progname = nil, to_email = false, &block)
    add(DEBUG, nil, progname, to_email, &block)
  end
end
