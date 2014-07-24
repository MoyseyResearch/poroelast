classdef Times < handle

  properties
    times;
    unit;
  end

  methods

    function obj = Times(times,unit)
      obj.times=times;
      obj.unit=unit;
    end

  end

end
