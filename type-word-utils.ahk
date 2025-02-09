#Requires AutoHotkey v2.0
#SingleInstance Force
SetWorkingDir A_ScriptDir
FileEncoding "UTF-8"
#Include type-word-utils-language-strings.ahk
TraySetIcon A_ScriptDir "..\#stuff\keyboard.ico"

; Global variables x
global PhrasesGui := "", ListBox := "", SearchBox := "", Textbox := "", StatusBar := ""
global InsertBtn := "", AddBtn := "", RemoveBtn := ""
global Phrases := []
global PhrasesFile := "type-word-utils.txt"
global ActiveWinId := 0

; Create and show the main GUI
CreateGui()
LoadPhrases()

; Main GUI creation function
CreateGui() {
  global PhrasesGui, ListBox, SearchBox, Textbox, StatusBar, InsertBtn, AddBtn, RemoveBtn

  PhrasesGui := Gui(, "Phrases")
  PhrasesGui.Opt("+Resize +MinSize500x300")
  PhrasesGui.OnEvent("Size", GuiResize)

  ; Search box
  SearchBox := PhrasesGui.Add("Edit", "w200 vSearchBox", "Search phrases...")
  SearchBox.OnEvent("Change", SearchPhrases)

  ; Listbox for phrases
  ListBox := PhrasesGui.Add("ListBox", "w500 r40 vSelectedPhrase")
  ListBox.SetFont("s11")

  ; Textbox for new phrases
  Textbox := PhrasesGui.Add("Edit", "w500 vNewPhrase")

  ; Buttons
  InsertBtn := PhrasesGui.Add("Button", "w100 x10 y+10", "Insert")
  InsertBtn.OnEvent("Click", InsertPhrase)

  AddBtn := PhrasesGui.Add("Button", "w100 x+10", "Add")
  AddBtn.OnEvent("Click", AddPhrase)

  RemoveBtn := PhrasesGui.Add("Button", "w100 x+10", "Remove")
  RemoveBtn.OnEvent("Click", RemovePhrase)

  ; Status bar
  StatusBar := PhrasesGui.Add("StatusBar")

  ; Set up tooltips
  InsertBtn.ToolTip := "Insert selected phrase (Enter)"
  AddBtn.ToolTip := "Add new phrase (Ctrl+Enter)"
  RemoveBtn.ToolTip := "Remove selected phrase (Del)"

  ; Events
  PhrasesGui.OnEvent("Close", (*) => PhrasesGui.Hide())
  PhrasesGui.OnEvent("Escape", (*) => PhrasesGui.Hide())
  ListBox.OnEvent("DoubleClick", InsertPhrase)
}

; Load phrases from file
LoadPhrases() {
  global Phrases, PhrasesFile
  try {
    FileContent := FileRead(PhrasesFile)
    tempPhrases := StrSplit(FileContent, "`n", "`r")
    Phrases := []
    for phrase in tempPhrases {
      if (phrase != "") {
        Phrases.Push(phrase)
      }
    }
    UpdateListBox()
  } catch as e {
    MsgBox("Error loading phrases: " . e.Message)
  }
}

; Update ListBox with current phrases
UpdateListBox() {
  global ListBox, Phrases, StatusBar
  ListBox.Delete()
  for phrase in Phrases {
    if (phrase != "")
      ListBox.Add([phrase
      ])
  }
  StatusBar.SetText("Phrases: " . Phrases.Length)
}

; Search phrases
SearchPhrases(*) {
  global SearchBox, ListBox, Phrases
  searchTerm := SearchBox.Text
  if (searchTerm = "Search phrases...") {
    return
  }
  filteredPhrases := []
  for phrase in Phrases {
    if (InStr(phrase, searchTerm))
      filteredPhrases.Push(phrase)
  }
  ListBox.Delete()
  for phrase in filteredPhrases {
    ListBox.Add([phrase
    ])
  }
}

; Insert selected phrase
InsertPhrase(*) {
  global ListBox, PhrasesGui, ActiveWinId
  selectedText := ListBox.Text
  if (selectedText = "") {
    return
  }
  PhrasesGui.Hide()
  if (ActiveWinId) {
    WinActivate('ahk_id ' . ActiveWinId)
  }
  WinWaitNotActive "Phrases"
  A_Clipboard := selectedText
  SendInput "^v"
}

; Add new phrase
AddPhrase(*) {
  global Textbox, PhrasesFile, StatusBar
  newPhrase := Textbox.Text
  if (newPhrase != "") {
    FileAppend "`n" . newPhrase, PhrasesFile, "UTF-8"
    LoadPhrases()
    Textbox.Value := ""
    StatusBar.SetText("Added: " . newPhrase)
  }
}

; Remove selected phrase
RemovePhrase(*) {
  global ListBox, Phrases, PhrasesFile, StatusBar
  selectedText := ListBox.Text
  if (selectedText = "") {
    return
  }
  selectedIndex := ListBox.Value
  Phrases.RemoveAt(selectedIndex)
  FileDelete PhrasesFile

  ; Join the phrases with newlines
  joinedPhrases := ""
  for index, phrase in Phrases {
    if (index > 1) {
      joinedPhrases .= "`n"
    }
    joinedPhrases .= phrase
  }

  FileAppend joinedPhrases, PhrasesFile, "UTF-8"
  UpdateListBox()
  StatusBar.SetText("Removed phrase")
}

; Resize GUI elements
GuiResize(thisGui, MinMax, Width, Height) {
  global ListBox, Textbox, InsertBtn, AddBtn, RemoveBtn
  if (MinMax = -1) {
    return
  }

  ListBox.Move(, , Width - 20, Height - 150)
  Textbox.Move(, Height - 90, Width - 20)
  buttonY := Height - 60
  InsertBtn.Move(10, buttonY)
  AddBtn.Move(120, buttonY)
  RemoveBtn.Move(230, buttonY)
}

; Hotkeys
#HotIf WinActive('ahk_exe WINWORD.EXE') or WinActive('Phrases')

+Esc:: ExitApp

CapsLock & p::
CapsLock & ච::
~Esc:: PhrasesGui.Hide()

;* add currently highlighted phrase
^w:: {
  global ActiveWinId, Textbox, PhrasesGui
  ActiveWinId := WinGetID('A')
  A_Clipboard := ""
  Send "^c"
  if ClipWait(1) {
    Textbox.Value := A_Clipboard
  }
  PhrasesGui.Show()
}

;* show window
^q:: {
  global ActiveWinId, PhrasesGui
  ActiveWinId := WinGetID('A')
  PhrasesGui.Show()
  LoadPhrases()
}

#HotIf WinActive("Phrases")
Enter:: InsertPhrase()
^Enter:: AddPhrase()
Del:: RemovePhrase()