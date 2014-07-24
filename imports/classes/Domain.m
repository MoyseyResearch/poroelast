classdef Domain < handle

  properties
    title;
    geometry;
  end

  methods

    function obj = Domain(title,geometry)
      obj.title=title;
      obj.geometry=geometry;
    end

  end

end
