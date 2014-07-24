classdef Cycle < handle

  properties
    accept;
    reject;
    last;
    next;
    fitness;
    rank;
    dominating;
    dominatedBy;
  end

  methods

    function obj = Cycle(last)
      obj.last   = last;
      obj.next   = {};
      obj.reject = {};
    end

  end

end
