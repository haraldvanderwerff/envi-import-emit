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
; v.20230823a
;-

pro hw_emitter_doit, ev

  compile_opt idl2

  catch, theerror
  if theerror ne 0 then begin
    catch, /cancel
    void = dialog_message(!error_state.msg,/error,/center)
    widget_control, info.run_id, sensitive=0
    close, /all
    return
  endif

  ; update program status
  widget_control, ev.top, get_uvalue = info, /no_copy
  widget_control, info.options_id, get_value=options
  widget_control, info.rpath_id, get_value = rpath
  widget_control, info.upath_id, get_value = upath
  widget_control, info.mpath_id, get_value = mpath
  ; disable run button for as long as the module runs
  widget_control, info.run_id, sensitive=0
  
  ;H5_LIST, info.rpath
  ;H5_LIST, info.upath
  ;H5_LIST, info.mpath
  
  if rpath ne '' then begin
  
    ; get ref data
    wl = H5_GETDATA(info.rpath, '/sensor_band_parameters/wavelengths')
    fwhm = H5_GETDATA(info.rpath, '/sensor_band_parameters/fwhm')
    bbl = fix(H5_GETDATA(info.rpath, '/sensor_band_parameters/good_wavelengths'))
    ref = transpose(H5_GETDATA(info.rpath, '/reflectance'),[1,2,0])
    
    meta = H5_PARSE(info.rpath,/read_data)   
    lat = (meta.northernmost_latitude._data)[0]
    lon = (meta.westernmost_longitude._data)[0]
    res = (meta.spatialresolution._data)[0]
    css = (meta.spatial_ref._data)[0]
    map = "Geographic Lat/Lon, 1.5000, 1.5000, "+strtrim(lon,2)+", "+strtrim(lat,2)+", "+strtrim(res,2)+", "+strtrim(res,2)+", WGS-84, units=Degrees"

    ; get glt data
    glt_x = H5_GETDATA(info.rpath, '/location/glt_x')
    glt_y = H5_GETDATA(info.rpath, '/location/glt_y') 
    
  endif
  
  if mpath ne '' then begin
  
    ; get mask data
    msk = transpose(H5_GETDATA(info.mpath, '/mask'),[1,2,0])
    
    ; optionally get glt data
    if rpath eq '' then begin
      meta = H5_PARSE(info.mpath,/read_data)   
      lat = (meta.northernmost_latitude._data)[0]
      lon = (meta.westernmost_longitude._data)[0]
      res = (meta.spatialresolution._data)[0]
      css = (meta.spatial_ref._data)[0]
      map = "Geographic Lat/Lon, 1.5000, 1.5000, "+strtrim(lon,2)+", "+strtrim(lat,2)+", "+strtrim(res,2)+", "+strtrim(res,2)+", WGS-84, units=Degrees"
    
      glt_x = H5_GETDATA(info.mpath, '/location/glt_x')
      glt_y = H5_GETDATA(info.mpath, '/location/glt_y')
    endif
  endif
 
  ; write raw data if requested
  if options eq 0 then begin
 
    if rpath ne '' then begin
     ; get location data
     loc = [$ 
       [[H5_GETDATA(info.rpath, '/location/elev')]],$
       [[H5_GETDATA(info.rpath, '/location/lat')]],$
       [[H5_GETDATA(info.rpath, '/location/lon')]] ]
    
     ; write location data
     fname = info.spath+file_basename(info.rpath,'.nc')+'_loc.dat'
     hw_emitter_save_binary, fname, loc
     hw_emitter_save_header, fname, $
       'EMIT location data', $
       (size(loc))[1], $
       (size(loc))[2], $
       (size(loc))[3], $
       size(loc,/type), $
       bnames=['Elevation','Latitude','Longitude']  
    loc=1b ; remove loc data from memory

    ; write reflectance data
    fname = info.spath+file_basename(info.rpath,'.nc')+'_ref.dat'
    hw_emitter_save_binary, fname, ref
    hw_emitter_save_header, fname, $
      'EMIT reflectance data', $
      (size(ref))[1], $
      (size(ref))[2], $
      (size(ref))[3], $
      size(ref,/type), $
      bnames='Band '+strtrim(indgen(n_elements(wl)+1),2),$
      bbl=bbl,$
      fwhm=fwhm,$
      wl=wl
    endif
    
    ; get reflectance uncertainty data
    if upath ne '' then begin
      unc = transpose(H5_GETDATA(info.upath, '/reflectance_uncertainty'),[1,2,0])
      fname = info.spath+file_basename(info.rpath,'.nc')+'_unc.dat'
      hw_emitter_save_binary, fname, unc
      hw_emitter_save_header, fname, $
        'EMIT reflectance_uncertainty data', $
        (size(ref))[1], $
        (size(ref))[2], $
        (size(ref))[3], $
        size(ref,/type), $
        bnames='Band '+strtrim(indgen(n_elements(wl)+1),2),$
        bbl=bbl,$
        fwhm=fwhm,$
        wl=wl
      unc=1b ; remove unc data from memory
    endif
    
    ; write mask data
    if mpath ne '' then begin
      fname = info.spath+file_basename(info.rpath,'.nc')+'_msk.dat'
      hw_emitter_save_binary, fname, msk
      hw_emitter_save_header, fname, $
        'EMIT mask data', $
        (size(msk))[1], $
        (size(msk))[2], $
        (size(msk))[3], $
        size(msk,/type), $
        bnames=[$
          'Cloud Flag',$
          'Cirrus Flag',$
          'Water Flag',$
          'Spacecraft Flag',$
          'Dilated Cloud Flag',$
          'Aerosol optical depth (550nm)',$
          'Water vapor estimate (g/cm2)',$
          'Aggregated binary flags']
    endif  
    
    if mpath ne '' || rpath ne '' then begin
      ; write glt data
      fname = info.spath+file_basename(info.rpath,'.nc')+'_glt.dat'
      hw_emitter_save_binary,fname, [ [[glt_x]],[[glt_y]] ]
      hw_emitter_save_header, fname, $
        'EMIT geolookup table', $
        (size(glt_x))[1], $
        (size(glt_x))[2], $
        '2', $
        size(glt_x,/type), $
        map=map,$
        css=css,$
        bnames=['GLT_x','GLT_y']  
    endif
  endif
  
  ; write ref_geo or ref_msk_geo data
  if options ge 1 then begin
  
    if options eq 2 then begin
      ; write ref_msk_geo data
      msk = 1.0-reform(msk[*,*,7]) ; subset to the aggregated mask
      ref = ref / rebin(msk,[(size(msk))[1],(size(msk))[2],(size(ref))[3]]) ; apply the mask
      fname = info.spath+file_basename(info.rpath,'.nc')+'_ref_msk_geo.dat'
    endif else begin
      ; write ref_geo data
      msk = 1b ; remove mask data from memory
      fname = info.spath+file_basename(info.rpath,'.nc')+'_ref_geo.dat'
    endelse
 
    ;t1 = systime(/seconds)
 
    ; slow but certain...
;    openw, lun, fname, /get_lun 
;    temp = make_array($
;      (size(glt_x))[1]*(size(glt_x))[2],$
;      type=size(ref,/type),$
;      value = !values.f_nan)
;    for b = 0, (size(ref))[3]-1 do begin ; loop through the bands to safe memory
;      for i = 0l, n_elements(glt_x)-1 do begin ; TODO: should subset to valid pixels only
;        if glt_x[i] + glt_y[i] gt 0 then temp[i] = ref[ glt_x[i]-1,glt_y[i]-1,b ]
;      end
;      writeu, lun, temp  
;    end
;    free_lun, lun
    
    ; a bit more efficient
    openw, lun, fname, /get_lun 
    temp = make_array($
      (size(glt_x))[1]*(size(glt_x))[2],$
      type=size(ref,/type),$
      value = !values.f_nan)
    idx = where((glt_x + glt_y) gt 0,n_idx)
    for b = 0l, (size(ref))[3]-1 do begin
      for i = 0l, n_idx-1 do temp[idx[i]] = ref[ glt_x[idx[i]]-1,glt_y[idx[i]]-1,b ]
      writeu, lun, temp  
    end
    free_lun, lun
    
    ;t2 = systime(/seconds)
    ;print, 'timing: "',t2-t1
      
    hw_emitter_save_header, fname, $
      'EMIT geocorrected and masked reflectance data', $
      (size(glt_x))[1], $
      (size(glt_x))[2], $
      (size(ref))[3],$
      size(ref,/type), $
      bnames='Band '+strtrim(indgen(n_elements(wl)+1),2),$
      map=map,$
      css=css,$
      bbl=bbl,$
      fwhm=fwhm,$
      wl=wl
      
    ;hw_emitter_save_meta, fname, meta
  endif

  ; clear selected file after running, enable run button
  widget_control, info.run_id, sensitive = 1
  widget_control, info.rpath_id, set_value = ''
  widget_control, info.upath_id, set_value = ''
  widget_control, info.mpath_id, set_value = ''
  ;info.rpath = ''
  ;info.upath = ''
  ;info.mpath = ''
  widget_control, ev.top, set_uvalue = info

end
