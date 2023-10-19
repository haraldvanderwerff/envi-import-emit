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
; v.20230808a
;-

pro hw_emitter_about,ev

  compile_opt idl2
  
  catch, theerror
  if theerror ne 0 then begin
   catch, /cancel
   message = !error_state.msg
   void = dialog_message(message, /error,/center)
   return
  endif
  
  widget_control, ev.top, get_uvalue = info
  
  message = [ $
    info.program + ' version '+info.version,$
    '-----------------------------------------------',$
    'hw_EMITter reads EMIT NetCDF files and converts',$ 
    'the data to an ENVI readable format. The output',$
    'is either all the raw data and geolookup table ',$
    'for further processing, or an already geocoded ',$
    'data cube, optionally also with applied masks. ',$
    '-----------------------------------------------',$
    'Design & programming',$
    ' - Harald van der Werff',$
    ' ',$
    'Acknowledgements ',$
    ' - Bruno Portela', $
    ' ',$
    ' Contact', $
    ' - harald.vanderwerff -at- utwente.nl', $
    '-----------------------------------------------' ]

  void = dialog_message(message, title='About', $
    /info, /center)

end
