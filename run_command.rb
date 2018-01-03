#Function that accepts a bash command and timeout and returns an array with [exit_status, stdout, stderr]
require 'timeout'

def run_command(command, timeout)
 last_exit_status = -1
 # stdout, stderr pipes
 rout, wout = IO.pipe
 rerr, werr = IO.pipe

 pid = Process.spawn(command, :out => wout, :err => werr)
 begin
   Timeout.timeout(timeout) do
     _, status = Process.wait2(pid)
     last_exit_status = status.exitstatus
   end
 rescue Timeout::Error
   puts 'Timeout reached!'
   last_exit_status = 1
   Process.kill('TERM', pid)
 end

 # close write ends so we could read them
 wout.close
 werr.close

 stdout = rout.readlines.join("\n")
 stderr = rerr.readlines.join("\n")

 # dispose the read ends of the pipes
 rout.close
 rerr.close

 return [last_exit_status,stdout,stderr]
end
