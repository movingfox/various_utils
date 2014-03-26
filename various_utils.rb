module VariousUtils

  def self.random_number(length)
    rand((10**length)-1).to_s.center(length, rand(9).to_s).to_i
  end

end

