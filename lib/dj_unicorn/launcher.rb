$stdout.sync = $stderr.sync = true
$stdin.binmode
$stdout.binmode
$stderr.binmode

module DJUnicorn::Launcher
  
  # Creates the dj_unicorn master process
  #   * umask is whatever was set by the parent process at startup
  #     and can be set in config.ru and config_file, so making it
  #     0000 and potentially exposing sensitive log data can be bad
  #     policy.
  #   * don't bother to chdir("/") here since unicorn is designed to
  #     run inside APP_ROOT.  Unicorn will also re-chdir() to
  #     the directory it was started in when being re-executed
  #     to pickup code changes if the original deployment directory
  #     is a symlink or otherwise got replaced.
  def self.daemonize!(options)
    $stdin.reopen("/dev/null")
    
    # We only start a new process group if we're not being reexecuted
    unless ENV['DJ_UNICORN_REEXEC']
      # grandparent - reads pipe, exits when master is ready
      #  \_ parent  - exits immediately ASAP
      #      \_ grandchild: dj_unicorn master - writes to pipe when ready
      
      # Create main pipe and get grandparent PID
      rd, wr = IO.pipe
      grandparent = $$
      if fork
        # Grandparent process - does not write
        wr.close
      else
        # Parent Process
        rd.close # parent/grandchild do not need to write
        Process.setsid
        exit if fork # create grandchild and die
      end
      
      if grandparent == $$
        # Wait for the dj_unicorn master process to write
        # its PID on pipe
        master_pid = (rd.readpartial(16) rescue nil).to_i
        # Return failure code if process is root
        
        unless master_pid > 1
          warn "master failed to start, check stderr log for details"
          exit!(1)
        end
        exit 0
      else # unicorn master process
        options[:ready_pipe] = wr
      end
    end
  end
end