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

function  hw_emitter_read_config, cpath

  compile_opt idl2 ;,hidden
  
  cd, current = current
  
  cpath = cpath + path_sep() + 'config'
  
  default = { $
    
    cpath    : cpath, $                    ; config file path
    bpath    : current, $                  ; base path for data files
    rpath    : current, $                  ; RFL  file path
    upath    : current, $                  ; RFLUNCERT file path
    mpath    : current, $                  ; MASK file path
    spath    : current, $                  ; OUTPUT directory path
    options  : 2 $             		   ; OUTPUT options
  }

  catch, theerror
  if theerror ne 0 then begin
    catch, /cancel
    void = dialog_message(!error_state.msg,/error,/center)
    close,/all
    return, default
  endif
 
  if file_test(cpath,/read) eq 1 then begin
    openr, lun, cpath, /get_lun
    
    ; dummy for config file
    dummy = ''
    readf, lun, dummy
    ; Reflectance path
    rpath = ''
    readf, lun, rpath
    ; uncertainty path
    upath = ''
    readf, lun, upath
    ; mask path
    mpath = ''
    readf, lun, mpath
    ; OUTPUT path
    spath = ''
    readf, lun, spath
    ; OUTPUT options
    options = ''
    readf, lun, options
    options = strsplit(options,/extract)
    
    free_lun, lun
  
    return, { $
      cpath : cpath, $
      bpath : file_dirname(rpath), $
      rpath : rpath, $
      upath : upath, $
      mpath : mpath, $
      spath : spath, $
      options : long(options)  $
    }
  
  endif else return, default
  
end
