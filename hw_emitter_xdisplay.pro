;+
;   
;    This program is free software: you can redistribute it and/or modify
;    it under the terms of the GNU Lesser General Public License as published
;    by the Free Software Foundation, either version 3 of the License, or
;    (at your option) any later version.
;
;    This program is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU Lesser General Public License for more details.
;
;    You should have received a copy of the GNU Lesser General Public License
;    along with this program.  If not, see <http://www.gnu.org/licenses/>.
;
;-

;+
; v.20131101a
;-

pro hw_emitter_xdisplay_event, event

  ;compile_opt idl2,hidden
  
end

;+
; v.20131101a
;-

pro hw_emitter_xdisplay,title = title,text = text

  ; Establish defaults if keywords not specified
  if n_elements(title) eq 0 then title = 'xdisplay'

  base = widget_base($
    title = title, $
   ; /tlb_size_events, $
    /base_align_left, $
    /column)

  ; create a text widget to display the text
  void = widget_text($
    base, $
    xsize = 90, $
    ysize = 24, $
    /scroll, $
    value = text)

  device, get_screen_size=screensize
  if screensize[0] gt 2000 then $
    screensize[0] = screensize[0]/2 ; dual monitors?
  xcenter = screensize[0] / 2
  ycenter = screensize[1] / 2
  geom = widget_info(base, /geometry)
  xhalfsize = geom.scr_xsize / 2
  yhalfsize = geom.scr_ysize / 2
  xoffset = xcenter-xhalfsize
  yoffset = ycenter-yhalfsize

  widget_control, $
    base, $
    xoffset = xoffset, $
    yoffset = yoffset, $
    /realize
  
  xmanager, "hw_emitter_xdisplay", base, /no_block

end
