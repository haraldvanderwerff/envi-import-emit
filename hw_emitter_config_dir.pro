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

function hw_emitter_config_dir

  compile_opt idl2 ;,hidden
 
  if n_elements(config_dir) ne 1 then begin 
 
    ; increment if author_readme_text is changed 
    author_readme_version = 1 
 
    author_readme_text = $ 
       ['This is the user configuration directory', $ 
       'for EMITter software, developed by:', $ 
       '', $ 
       '    Faculty ITC,', $
       '    University of Twente', $ 
       '    Hengelosestraat 99', $
       '    7500 AA, Enschede', $ 
       '    The Netherlands', $ 
       '', $ 
       '(c) ITC, The Netherlands' ] 
 
    ; increment if app_readme_text is changed 
    app_readme_version = 1       
 
    app_readme_text = $ 
      ['This is the configuration directory', $ 
       'for EMITter software', $ 
       '', $ 
       'it is safe to remove this directory,', $ 
       'as it will be recreated on demand.', $ 
       'Note that all settings will revert', $
       'to their defaults.'] 
 
    config_dir = app_user_dir( $
      'itc', $
      'ITC, University of Twente, Netherlands', $ 
      'emitter', 'EMITter', $ 
      app_readme_text, app_readme_version, $ 
      author_readme_text=author_readme_text, $ 
      author_readme_version=author_readme_version, $ 
      restrict_appversion='1', /restrict_family) 
 
  endif 
 
  return, config_dir 
 
end
