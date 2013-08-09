require 'spec_helper'

# Process structure
# grandparent - reads pipe, exits when master is ready
#  \_ parent  - exits immediately ASAP
#      \_ dj_unicorn master - writes to pipe when ready

describe DJUnicorn::Launcher do
  before(:each) do
    @mod = DJUnicorn::Launcher
  end
  
  describe "daemonize!" do
    it "does not start a new process group if we are reexecuted" do
      ENV['DJ_UNICORN_REEXEC'] = 'true'
      @mod.should_not_receive(:fork)
      @mod.daemonize!({})
    end
    
    describe "grandparent process" do
      before(:each) do
        ENV['DJ_UNICORN_REEXEC'] = nil
      end
      
      it "forks to create the parent process" do
        stub_io_pipe_with_read
        @mod.should_receive(:fork).and_return(123)
        capture_sysexit { @mod.daemonize!({}) }
      end
      
      it "waits for a child process to write on pipe before exiting" do
        rd,wr = stub_io_pipe
        
        # For this test we want to avoid the grandparent
        # to close the pipe
        wr.stub(:close)
        
        th = Thread.new do
          capture_sysexit { @mod.daemonize!({}) }
        end
        th.should be_alive
        wr.syswrite(245.to_s)
        th.join(5)
        th.should_not be_alive
      end
    end
    
    describe "parent process" do
      
    end
    
    describe "dj_master process" do
      
    end
  end
end