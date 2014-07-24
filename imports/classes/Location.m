classdef Location < handle

  properties
    title;
    location;
  end

  methods

    function obj = Location(title,location)
      obj.title=title;
      obj.location=location;
    end

  end

end
