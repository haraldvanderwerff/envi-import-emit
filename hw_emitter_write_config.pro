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
; v.20230807a
;-

pro hw_emitter_write_config,ev

  compile_opt idl2 ;,hidden

  catch, theerror
  if theerror ne 0 then begin
    catch, /cancel
    void = dialog_message(!error_state.msg,/error,/center)
    close,/all
    return
  endif
  
  widget_control, ev.top, get_uvalue = info
  widget_control, info.options_id, get_value=options
  
  openw, lun, info.cpath, /get_lun

  printf, lun, info.cpath
  printf, lun, info.rpath
  printf, lun, info.upath
  printf, lun, info.mpath
  printf, lun, info.spath
  printf, lun, string(options)
  
  free_lun, lun

end
