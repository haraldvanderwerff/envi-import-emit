pro hw_emitter_compile

compile_opt idl2

;RESOLVE_ROUTINE, Name, /COMPILE_FULL_FILE, /EITHER, /IS_FUNCTION, /NO_RECOMPILE, /QUIET, /SKIP_EXISTING

;resolve_routine,'hw_emitter_compile'

resolve_routine,'hw_emitter_config_dir',/is_function
resolve_routine,'hw_emitter_read_config',/is_function
resolve_routine,'hw_emitter_write_config'

resolve_routine,'hw_emitter_save_meta'
resolve_routine,'hw_emitter_save_header'
resolve_routine,'hw_emitter_save_binary'

resolve_routine,'hw_emitter_debug'
resolve_routine,'hw_emitter_license'
resolve_routine,'hw_emitter_about'
resolve_routine,'hw_emitter_xdisplay'

resolve_routine,'hw_emitter_doit'

resolve_routine,'hw_emitter',/compile_full_file

resolve_all,/continue_on_error

SAVE, /ROUTINES, FILENAME = 'hw_emitter.sav'

end
