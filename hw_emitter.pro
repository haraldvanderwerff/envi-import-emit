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
; NAME:        
;       HW_EMITTER
; PURPOSE:              
;       Convert EMIT NetCDF data to ENVI readable format
; EXPLANATION:               
;               
; CALLING SEQUENCE: 
;       HW_EMITTER
;    
; INPUT PARAMETERS:     
;       None, all input is interactively acquired.
;
; OUTPUTS:
;       ENVI images (with headers):
;       <filename>.dat          - reflectance data
;       <filename>_unc.dat      - reflectance uncertainty data
;       <filename>_loc.dat      - lat, lon and elevation 
;       <filename>_msk.dat      - atmosphere and water masks
;       <filename>_glt.dat      - geolookuptables
;       <filename>_geo.dat      - geocorrected reflectance data
;       <filename>_msk_geo.dat  - geocorrected and masked reflectance data
;                              
; OPTIONAL INPUT KEYWORD:
;       None.
;
; PROCEDURE CALLS:
;       None.
;
; MODIFICATION HISTORY: 
;       1.0 Written,       hvdw, Summer 2023
;- 

;+
; v.20230808a
;-

pro hw_emitter_event, ev

  compile_opt idl2

  catch, theerror
  if theerror ne 0 then begin
    catch, /cancel
    void = dialog_message(!error_state.msg, /error,/center)
    return
  endif

  widget_control, ev.id,  get_uvalue = id
  widget_control, ev.top, get_uvalue = info
  config = hw_emitter_read_config( hw_emitter_config_dir() )

  case id of
    'R' : begin
              newpath = dialog_pickfile( $
                dialog_parent = ev.top, $
                title = 'Please select an EMIT reflectance data file', $
                filter = [ '*RFL_*.nc','*.nc' ], $
                path = file_dirname(info.rpath), $
                /read, $
                /must_exist )
              if newpath[0] ne '' && H5F_IS_HDF5(newpath[0]) ne 1 then begin
                  newpath[0] = ''
                  msg = 'This is not a valid HDF5 file'
                  void = dialog_message(msg, /error,/center)
              endif
              info.rpath = newpath[0]
              widget_control, ev.top, set_uvalue = info
              widget_control, info.rpath_id, set_value = file_basename(newpath[0])
            end
    'U' : begin
              newpath = dialog_pickfile( $
                dialog_parent = ev.top, $
                title = 'Please select a corresponding EMIT uncertainty file', $
                filter = [ '*RFLUNCERT_*.nc','*.nc' ], $
                path = file_dirname(info.upath), $
                /read, $
                /must_exist )
              if newpath[0] ne '' && H5F_IS_HDF5(newpath[0]) ne 1 then begin
                  newpath[0] = ''
                  msg = 'This is not a valid HDF5 file'
                  void = dialog_message(msg, /error,/center)
              endif
              info.upath = newpath[0]
              widget_control, ev.top, set_uvalue = info
              widget_control, info.upath_id, set_value = file_basename(newpath[0])
          end
    'M' : begin
              newpath = dialog_pickfile( $
                dialog_parent = ev.top, $
                title = 'Please select a corresponding EMIT mask file', $
                filter = [ '*MASK_*.nc','*.nc' ], $
                path = file_dirname(info.mpath), $
                /read, $
                /must_exist ) 
              if newpath[0] ne '' && H5F_IS_HDF5(newpath[0]) ne 1 then begin
                  newpath[0] = ''
                  msg = 'This is not a valid HDF5 file'
                  void = dialog_message(msg, /error,/center)
              endif
              info.mpath = newpath[0]
              widget_control, ev.top, set_uvalue = info
              widget_control, info.mpath_id, set_value = file_basename(newpath[0])
          end
    'S'      : begin
                 newpath = dialog_pickfile( $
                   dialog_parent = ev.top, $
                   title = 'Please select an output directory',$
                   path = file_dirname(info.spath),$
                   /directory,$
                   /write,$
                   /must_exist )
                 if newpath ne '' then begin
                   info.spath = newpath[0]
                   widget_control, ev.top, set_uvalue = info
                   widget_control, info.spath_id, set_value = newpath[0]
                 endif
              end
    'OPTIONS': widget_control, ev.top, set_uvalue = info
    'RUN'    : hw_emitter_doit, ev 
    ;'HELP'   : hw_emitter_help, ev
    'LICENSE': hw_emitter_license,ev
    'DEBUG'  : hw_emitter_debug,ev
    'ABOUT'  : hw_emitter_about,ev
    'SAVE'   : begin
                 hw_emitter_write_config,ev
                 return
               end
    'DONE'   : begin    
                 widget_control, ev.top, /destroy
                 return
               end      
    else     : print, 'DEBUG: unknown event.id '+string(id)
    
  endcase
 
  ; block or release the run button
  widget_control, info.options_id, get_value=options
  widget_control, info.rpath_id, get_value = rpath
  widget_control, info.upath_id, get_value = upath
  widget_control, info.mpath_id, get_value = mpath
  widget_control, info.spath_id, get_value = spath
  flag = 0
  if rpath ne '' then flag = 1
  if rpath eq '' && options eq 0 then flag = 1
  if upath ne '' && options eq 0 then flag = 1
  if mpath ne '' && options eq 0 then flag = 1
  if mpath eq '' && options eq 2 then flag = 0
  if spath eq '' then flag = 0
  widget_control, info.run_id, sensitive=flag 

end

;+
; hw_emitter, main program, state definition and GUI
; v.20230808a
;-

pro hw_emitter

  compile_opt idl2
  
  ; catch errors and display in window
  catch, theerror
  if theerror ne 0 then begin
    catch, /cancel
    void = dialog_message(!error_state.msg,/error,/center)
    return
  endif

  ; suppress error messages to console
  !except = 0
  
  ; get program configuration
  config = hw_emitter_read_config( hw_emitter_config_dir() )

  ; info structure with program settings & status
  info = { $
    program   : 'EMITter', $
    version   : '20230808a', $
    author    : 'Harald van der Werff', $
    copyright : 'University of Twente', $
    copyyear  : '2023',$
    cpath     : config.cpath, $
    rpath     : config.rpath, $
    mpath     : config.rpath, $
    upath     : config.rpath, $
    spath     : config.rpath, $
    rpath_id  : 0l, $
    mpath_id  : 0l, $
    upath_id  : 0l, $
    spath_id  : 0l, $
    options_id: 0l, $
    run_id    : 0l  $
  }

  base = widget_base(title=info.program+' '+info.version,mbar=mbar,/column )
  
  m1 = widget_button(mbar,value='Program',/menu)
    void = widget_button($
      m1,$
      value='Save settings',$
      uvalue='SAVE',$
      /separator)
    void = widget_button($
      m1,$
      value='Exit program',$
      uvalue='DONE')
  m2 = widget_button($
    mbar,$
    value='Help',$
    /menu,$
    /help)
   ;void = widget_button($
    ;  m2,$
    ;  value='Help',$
    ;  uvalue='HELP')
    ;void = widget_button($
    ;  m2,$
    ;  value='Debug',$
    ;  uvalue='DEBUG',$
    ;  /separator)
    void = widget_button($
      m2,$
      value='License',$
      uvalue='LICENSE',$
      /separator)
    void = widget_button($
      m2,$
      value='About',$
      uvalue='ABOUT',$
      /separator)

   base2 = widget_base(base, row=4, /frame)
     void = widget_label(base2,value='Input selection',/align_left)
     void = widget_label(base2,value='')
     void = widget_button(base2, value = 'Select *RFL*', $
       uvalue = 'R', xsize=150)
     info.rpath_id = widget_text(base2, xsize=50, $
       value = '') ;file_dirname(config.rpath,/mark_directory))
     void = widget_button(base2, value = 'Select *RFLUNCERT*', $
       uvalue = 'U', xsize=150)
     info.upath_id = widget_text(base2, xsize=50, $
       value = '') ; file_dirname(config.upath,/mark_directory))
     void = widget_button(base2, value = 'Select *MASK*', $
       uvalue = 'M', xsize=150)
     info.mpath_id = widget_text(base2, xsize=50, $
       value = ''); file_dirname(config.mpath,/mark_directory))
   
   base3 = widget_base(base, row=2, /frame)
     void = widget_label(base3,value='Output selection',/align_left)
     void = widget_label(base3,value='')
     void = widget_button(base3, value = 'Select directory', $
       uvalue = 'S', xsize=150)
     info.spath_id = widget_text(base3, xsize=50, $
       value = '') ;config.spath)

   base4 = widget_base(base,/column,/frame)
     void = widget_label($
       base4,$
       value='Requested output',$
       /align_left)
     values = [ $
       '1 - Reflectance, uncertainty, geolocation, masks and geolookup tables',$
       '2 - Only the Geocoded reflectance data',$
       '3 - Geocoded and masked reflectance data']
     info.options_id = cw_bgroup($
       base4,$
       values,$
       set_value = config.options,$
       /col,$
       /exclusive,$
       uvalue = 'OPTIONS')
     info.run_id = widget_button($
       base,$
       value = 'Run', $
       uvalue = 'RUN',$
       sensitive = 0,$
       xsize = 80)
   
    base5 = widget_base($
      base,$
      /row,$
      /frame)
      void = widget_label($
        base5,$
        value = 'Copyright '+info.copyyear+' by '+info.author+', '+info.copyright+'.')

  widget_control,base,/realize,set_uvalue = info

  xmanager,'hw_emitter',base,/no_block

end 
