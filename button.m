classdef button < dynamicprops
   properties
      UiHandle
   end
   methods
      function obj = button(pos)
         if nargin > 0
            if length(pos) == 4
               obj.UiHandle = uicontrol('Position',pos,...
                  'Style','pushbutton');
            else
               error('Improper position')
            end
         end
      end
   end
end

