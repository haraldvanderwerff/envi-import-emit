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

pro hw_emitter_save_header, fname, desc, ns, nl, nb, dt,map=map,css=css,bnames=bnames,wl=wl,fwhm=fwhm,bbl=bbl

  compile_opt idl2

  catch, theerror
  if theerror ne 0 then begin
    catch, /cancel
    print,!error_state.msg
    return
  endif
   
  ; open file, and attach extension .hdr
  openw,  lun, fname+'.hdr', /get_lun
  
  ; add scene specific header info
  printf, lun, 'ENVI description = {'
  printf, lun, desc
  printf, lun, '}'
  printf, lun, 'samples = '  +strtrim(ns,2)
  printf, lun, 'lines = '    +strtrim(nl,2)
  printf, lun, 'bands = '    +strtrim(nb,2)
  printf, lun, 'data type = '+strtrim(dt,2)
  
  ; add standard header info
  printf, lun, 'header offset = 0'
  printf, lun, 'file type = ENVI Standard'
  printf, lun, 'interleave = bsq'
  printf, lun, 'sensor type = Unknown'
  printf, lun, 'byte order = 0'
  
  ; add coordinate system, if set
  if keyword_set(map) then begin
    printf, lun, 'map info = {'
    printf, lun, map
    printf, lun, '}'
  endif
  
  ; add coordinate transformation system, if set
  if keyword_set(css) then begin
    printf, lun, 'coordinate_system_string = {'
    printf, lun, css
    printf, lun, '}'
  endif
  
  ; add band names, if set
  if keyword_set(bnames) then begin
    printf, lun, 'band names = {'
    if n_elements(bnames) eq 1 $
      then printf, lun, bnames $
      else printf, lun, [ bnames[0:nb-2]+',',bnames[nb-1] ]
    printf, lun, '}'
  endif
  
  ; add wavelength table, if set
  if keyword_set(wl) then begin
   printf, lun, 'wavelength units = Nanometers'
   printf, lun, 'wavelength = {'
   printf, lun, [strtrim(wl[0:nb-2],2)+',',strtrim(wl[nb-1],2)]
   printf, lun, '}'
  endif
  
  ; add fwhm list, if set
  if keyword_set(fwhm) then begin
   printf, lun, 'fwhm = {'
   printf, lun, [strtrim(fwhm[0:nb-2],2)+',',strtrim(fwhm[nb-1],2)]
   printf, lun, '}'
  endif
  
  ; add bad band list, if set
  if keyword_set(bbl) then begin
   printf, lun, 'bbl = {'
   printf, lun, [strtrim(bbl[0:nb-2],2)+',',strtrim(bbl[nb-1],2)]
   printf, lun, '}'
  endif

  ; free lun and close file
  free_lun, lun

end
