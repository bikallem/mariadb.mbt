///|
#internal(ffi, "")
#external
pub type CString

///|
#internal(ffi, "")
pub extern "c" fn moonbit_string(cptr : CString) -> String = "moonbit_string"
