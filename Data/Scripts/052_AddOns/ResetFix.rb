class Reset < Exception
  
end

module Graphics
  class << self 
    unless self.method_defined?(:f12_update)
      alias_method(:f12_update, :update)
      alias_method(:f12_transition, :transition)
    end
    def update(*args)
      done = false
      while !done
        begin
          f12_update(*args)
          done = true
        rescue Reset  
          pid = spawn ('Game.exe')
          Process.detach(pid)
          sleep(0.01)
          exit
        end
      end
    end
    def transition(*args)
      done = false
      while !done
        begin
          f12_transition(*args)
          done = true
        rescue Reset
          pid = spawn ('Game.exe')
          Process.detach(pid)
          sleep(0.01)
          exit
        end
      end
    end
  end
end