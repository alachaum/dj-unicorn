def stub_io_pipe
  pipe = IO.pipe
  IO.stub(:pipe).and_return(pipe)
  return pipe
end

def stub_io_pipe_with_read
  rd,wr = IO.pipe
  IO.stub(:pipe).and_return([rd,wr])
  rd.stub(:readpartial).with(any_args).and_return(327)
  return [rd,wr]
end