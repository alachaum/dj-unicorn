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
        wr.syswrite(245.to_s) #without this call rspec would hang
        th.join
        th.should_not be_alive
      end
    end
    
    describe "parent process" do
      before(:each) do
        ENV['DJ_UNICORN_REEXEC'] = nil
      end
      
      it "forks to create the dj_unicorn master process and exits" do
        @mod.should_receive(:fork).once.ordered.and_return(nil)
        @mod.should_receive(:fork).once.ordered.and_return(123)
        capture_sysexit { @mod.daemonize!({}) }
      end
    end
    
    describe "dj_unicorn master process" do
      # Haven't found a way to test this part yet
      #
      # before(:each) do
      #   ENV['DJ_UNICORN_REEXEC'] = nil
      #   Process.stub(:setsid)
      #   @mod.stub(:fork).and_return(nil)
      # end
      # 
      # it "captures the write_io as 'ready_pipe' on options hash" do
      #   wr,rd = stub_io_pipe
      #   options = {}
      #   capture_sysexit { @mod.daemonize!(options) }
      #   options[:ready_pipe].should == wr
      # end
    end
  end
end