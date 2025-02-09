#Requires AutoHotkey v2.0
#SingleInstance Force
#HotString * ?

#HotIf GetKeyboardLayout() = -257948581
::,::්‍ර
#HotIf

::ග::.
::ල::,
::ඝ::ග
::.ග::ඟ
::.ළ::ළ
::ළ::ල
::.ද::ඳ

::ෙෙ::ෛ
::.ේ::ේ
::.ෝ::ෝ
::ෞ::ෞ

::අා::ආ
::අැ::ඇ
::ඔ්::ඕ

;* temp

^+F12:: MsgBox GetKeyboardLayout()

GetKeyboardLayout() {
  try {
    Focused := ControlGetClassNN(ControlGetFocus("A"))
  } catch {
    return ''
  }
  CtrlID := ControlGetHwnd(Focused, "A")
  ThreadID := DllCall("GetWindowThreadProcessId", "Ptr", CtrlID, "Ptr", 0)
  return DllCall("GetKeyboardLayout", "UInt", ThreadID, "Ptr")
}
