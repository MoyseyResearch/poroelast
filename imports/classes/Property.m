classdef Property < handle

  properties
    title;
    abv;
    unit;
  end

  methods

    function obj = Property(title,abv,unit)
      obj.title=title;
      obj.abv=abv;
      obj.unit=unit;
    end

  end

end
