classdef Objective < handle

  properties
    location;
    times;
    instrument;
    data;
    weight;
  end

  methods

    function obj = Objective(location,times,instrument,data,weight)
      obj.location=location;
      obj.times=times;
      obj.instrument=instrument;
      obj.data=data;
      obj.weight=weight;
    end

  end

end
