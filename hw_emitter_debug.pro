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

pro hw_emitter_debug,ev

  compile_opt idl2
  
  catch, theerror
  if theerror ne 0 then begin
    catch, /cancel
    void = dialog_message(!error_state.msg,/error,/center)
    return
  endif
    
  widget_control, ev.top, get_uvalue = info
  
  widget_control, info.rpath_id, get_value=rpath
  widget_control, info.upath_id, get_value=upath
  widget_control, info.mpath_id, get_value=mpath
  widget_control, info.spath_id, get_value=spath
  widget_control, info.options_id, get_value=options
  
  help, ev,  /structure,output = message1
  help, info,/structure,output = message2
  
  message = [$
    'EVENT',message1,'', $
    'EVENT.TOP',message2,'']
    
  ;H5_LIST, info.rpath
  ;H5_LIST, info.upath
  ;H5_LIST, info.mpath  
    
  void = dialog_message(message, title='DEBUG', $
    /info, /center)  
    
  ;hw_emitter_xdisplay, $
  ;  title = info.program + ' - DEBUG',$
  ;  text = message

end
