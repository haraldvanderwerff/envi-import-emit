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

pro hw_emitter_save_binary,fname,data

  compile_opt idl2

  catch, theerror
  if theerror ne 0 then begin
    catch, /cancel
    print,!error_state.msg
    return
  endif

  ; open file
  openw, lun, fname, /get_lun
  
  ;write array to disk
  writeu, lun, data
  
  ; free lun and close file
  free_lun, lun

end
