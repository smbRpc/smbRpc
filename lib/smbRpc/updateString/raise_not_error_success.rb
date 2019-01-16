class String

  def raise_not_error_success(funcName)
    winError = self[-4,4].unpack("V")[0]
    error = WindowsError::Win32.find_by_retval(winError)[0]
    error = WindowsError::NTStatus.find_by_retval(winError)[0] if error.nil?
    raise "%s Fail, WinError: %s 0x%08x"%[funcName, "UNKNOWN ERROR CODE", winError ] if error.nil?
    error.value == 0? error.value : (raise "%s Fail, WinError: %s %s"%[funcName, error.name, error.description])
  end

end
