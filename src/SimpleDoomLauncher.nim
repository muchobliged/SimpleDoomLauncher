import backgroundlogic, extraStyles
import std/[strutils, os, osproc]
import nimgl/[opengl, glfw], nimgl/imgui, nimgl/imgui/[impl_opengl, impl_glfw]
import tinydialogs


#TODO   Flatpak build?            Compile to C?



when defined(windows):
  proc glfwGetWin32Window(window: GLFWWindow): pointer {.importc: "glfwGetWin32Window".}

  proc DwmSetWindowAttribute(hwnd: pointer, dwAttribute: int32, pvAttribute: pointer, cbAttribute: int32): int32 {.importc: "DwmSetWindowAttribute", stdcall, dynlib: "dwmapi.dll".}

  proc enableDarkTitleBar*(window: GLFWWindow) =
    let hwnd = glfwGetWin32Window(window)
    if hwnd.isNil:
      return
    const DWMWA_USE_IMMERSIVE_DARK_MODE = 20
    var value: int32 = 1
    let result = DwmSetWindowAttribute(
      hwnd,
      DWMWA_USE_IMMERSIVE_DARK_MODE,
      addr value,
      int32(sizeof(value))
    )
    #if result != 0:
      #echo "Failed to enable dark title bar (error code: ", result, ")"

#let TargetFPS = 60.0
let BackgroundFPS = 10.0
proc fpsLimit(win: GLFWWindow) =
  var lastFrameTime = glfwGetTime()
  let focused = win.getWindowAttrib(GLFWHovered) == GLFW_TRUE
  let hovered = win.getWindowAttrib(GLFWFocused) == GLFW_TRUE
  let currentTime = glfwGetTime()
  let delta = currentTime - lastFrameTime
  #let targetDelta = if focused: 1.0 / TargetFPS else: 1.0 / BackgroundFPS
  let targetDelta = 1.0 / BackgroundFPS

  if delta < targetDelta and not focused and not hovered:
      let sleepMs = int((targetDelta - delta) * 1000.0)
      if sleepMs > 0:
          sleep(sleepMs)

  lastFrameTime = glfwGetTime()




proc hyperlink(text, url: string) =
  igText(text)
  if igIsItemHovered():
    igSetMouseCursor(ImGuiMouseCursor.Hand)
  if igIsItemClicked(ImGuiMouseButton.Left):
    when defined(linux):
      discard execProcess("xdg-open " & quoteShell(url))
    elif defined(windows):
      discard startProcess("explorer.exe", args = [quoteShell(url)], options = {poDaemon})



const RawIconData = staticRead("../assets/icon.raw")

var img = GLFWImage(
  width: 64.int32,
  height: 64.int32,
  pixels: cast[ptr cuchar](RawIconData.cstring)
)

proc setBuffer(buf: var array[256, char], text: string) =     #set igInputText text
  let len = min(text.len, 255)
  for i in 0 ..< len:
    buf[i] = text[i]
  buf[len] = '\0'



var shouldOpenAddPort: bool = false
var shouldAddDragWAD: bool = false
var dragPath: string = ""


proc main() =
  doAssert glfwInit()

  glfwWindowHint(GLFWContextVersionMajor, 3)
  glfwWindowHint(GLFWContextVersionMinor, 3)
  #glfwWindowHint(GLFWOpenglForwardCompat, GLFW_TRUE)           #Seems like i don't need this without MacOS build?
  glfwWindowHint(GLFWOpenglProfile, GLFW_OPENGL_CORE_PROFILE)
  glfwWindowHint(GLFWResizable, GLFW_FALSE)



  #[let monitor = glfwGetPrimaryMonitor()
  let vidmode = monitor.getVideoMode()
  var appRes = @[(vidmode.width / 3).int32, (vidmode.width / 3 * 0.75).int32]]#


  var w: GLFWWindow = glfwCreateWindow(800, 600, "Simple Doom Launcher", icon = false)
  if w == nil:
    discard messageBox("Error", "Failed to create GLFW window.\n\nMake sure your graphics drivers are up to date.", Ok, Error, Yes)
    quit(-1)

  when defined(windows):
    enableDarkTitleBar(w)

  w.setWindowIcon(1, img.addr)

  w.makeContextCurrent()

  doAssert glInit()



  let context = igCreateContext()

  let io = igGetIO()
  io.iniFilename = nil        #disable imgui saves


  doAssert igGlfwInitForOpenGL(w, true)
  doAssert igOpenGL3Init()


  io.setClipboardTextFn = proc(userData: pointer; text: cstring) {.cdecl.} =      #fix for clipboard
    cast[GLFWwindow](userData).setClipboardString($text)
  io.getClipboardTextFn = proc(userData: pointer): cstring {.cdecl.} =
    return cast[cstring](cast[GLFWwindow](userData).getClipboardString())
  io.clipboardUserData = w



  proc dropCallback(window: GLFWWindow; count: int32; paths: cstringArray) {.cdecl.} =    # drag-n-drop system
    for i in 0 ..< count:
      let pathCString: cstring = paths[i]
      let path: string = $pathCString

      #echo "File dropped from OS: ", path

      if ifExtensionCorrect(path):
        shouldAddDragWAD = true
        dragPath = path
      elif isExecutable(path):
        shouldOpenAddPort = true
        dragPath = path



  discard w.setDropCallback(dropCallback)





  var textBuf: array[256, char]
  textBuf[0] = '\0'

  var confCommandsTextBuf: array[256, char]
  confCommandsTextBuf[0] = '\0'

  let style = igGetStyle()

  setSelectedStyle(state.styleIndex)

  var iwadList: seq[string]
  var pwadList: seq[string]
  var currentText: string
  var canAddPort: bool = false
  var wantToDeletePort: bool = false
  var showAbout: bool = false
  var canSaveConfPort: bool = true
  var allowExtraFormats: bool = true
  var useFlatpak: bool = false
  var doPortable: bool = state.doPortable
  var closeOnLaunch: bool = state.closeOnLaunch
  var selectedFoldIWAD: string = ""
  var selectedFoldPWAD: string = ""
  var comboIndexIWADBehav: int32 = 0
  var comboIndexFlatpak: int32 = 0
  var showAddPortModal = false
  var showConfRenameModal = true
  var showSettingsModal = true
  var showPortConfigModal = true
  var selectedPortExec: string = ""
  var configuredPort: int = -1


  if state.ports.len > 0:
    iwadList = walkSelectedDir(state.defaultIWADDirectory, if state.ports[state.selectedPort].allowExtraFormats: allExtensions else: @[".wad"])
    pwadList = walkSelectedDir(state.defaultPWADDirectory, if state.ports[state.selectedPort].allowExtraFormats: allExtensions else: @[".wad"])



#----------------------------------------------------
#--------------- system window begin ----------------
#----------------------------------------------------

  while not w.windowShouldClose:
    fpsLimit(w)
    let itemHeight = igGetFontSize() + style.framePadding.y * 2.0
    let viewport = igGetMainViewport()
    let windowCenter = ImVec2(
      x: viewport.pos.x + viewport.size.x * 0.5,
      y: viewport.pos.y + viewport.size.y * 0.5
      )
    let mainFlags = cast[ImGuiWindowFlags](ImGuiWindowFlags.NoTitleBar.int or ImGuiWindowFlags.NoMove.int or ImGuiWindowFlags.NoBringToFrontOnFocus.int)
    let mainFlags2 = cast[ImGuiWindowFlags](ImGuiWindowFlags.NoTitleBar.int or ImGuiWindowFlags.NoMove.int or ImGuiWindowFlags.NoBringToFrontOnFocus.int or ImGuiWindowFlags.NoResize.int)

    let isMouseHoveringLeftWindow = igIsMouseHoveringRect(
      ImVec2(x: 0, y: 0), #ImVec2(x: 25.0, y: itemHeight),
      ImVec2(x: 300.0, y: viewport.size.y),    #ImVec2(x: 300.0, y: viewport.size.y - itemHeight),
      false
      )                       #hack to make left window resizable only from right border
    var leftWindowAvailSize: ImVec2
    var rightWindowAvailSize: ImVec2
    glfwPollEvents()
    igOpenGL3NewFrame()
    igGlfwNewFrame()
    igNewFrame()


#----------------------------------------------------
#-------------- left main window begin --------------
#----------------------------------------------------

    igSetNextWindowPos(ImVec2(x: 0, y: 0), ImGuiCond.Always, ImVec2(x: 0, y: 0))
    igSetNextWindowSize(ImVec2(x: state.leftWindowWidth, y: viewport.size.y), ImGuiCond.FirstUseEver)
    igSetNextWindowSizeConstraints(ImVec2(x: 50, y: viewport.size.y), ImVec2(x: 150, y: viewport.size.y))

    igBegin("##1", nil, if isMouseHoveringLeftWindow: mainFlags else: mainFlags2)
    state.leftWindowWidth = igGetWindowWidth()

    let leftWindowHovered = igIsMouseHoveringRect(
      ImVec2(x: 0.0, y: itemHeight),
      ImVec2(x: state.leftWindowWidth, y: viewport.size.y - itemHeight),
      false
      )                       #to hide or show scrollbar


    igGetContentRegionAvailNonUDT(leftWindowAvailSize.addr)


    if shouldOpenAddPort:
      if showAddPortModal:
        selectedPortExec = dragPath           # drag into already opened AddPortModal
        shouldOpenAddPort = false
      elif not isMouseHoveringLeftWindow:     # allow drop-add only in left side of the window
        shouldOpenAddPort = false

    if igButton("Add Port", ImVec2(x: leftWindowAvailSize.x, y: 0)) or shouldOpenAddPort:
      igOpenPopup("Add Port##999")
      showAddPortModal = true
      selectedPortExec = ""
      currentText = ""
      textBuf[0] = '\0'
      allowExtraFormats = true
      canAddPort = false
      comboIndexIWADBehav = 0
      comboIndexFlatpak = 0
      when defined(linux):
        useFlatpak = false
      if shouldOpenAddPort:
        shouldOpenAddPort = false
        selectedPortExec = dragPath

#----------------------------------------------------
#-------------- Add Port popup begin ----------------
#----------------------------------------------------


    igSetNextWindowSize(ImVec2(x: viewport.size.x / 2.5f, y: viewport.size.y / 2), ImGuiCond.Appearing)
    igSetNextWindowPos(windowCenter, ImGuiCond.Appearing, ImVec2(x: 0.5f, y: 0.5f))
    if igBeginPopupModal("Add Port##999", showAddPortModal.addr, cast[ImGuiWindowFlags](ImGuiWindowFlags.NoResize.int)):
      if igIsKeyPressed(256, false):          #for some reason nimgl bindings don't work, so 256 = Escape
        showAddPortModal = false
      var isChanged: bool = false
      igSeparator()
      igText("")
      var availReg: ImVec2
      var textSize: ImVec2
      var foldText: string
      igGetContentRegionAvailNonUDT(availReg.addr)
      if isExecutable(selectedPortExec):
        foldText = extractFilename(selectedPortExec)
      else:
        foldText = "Select executable"

      var buttSize = availReg.x/1.5f

      igSetCursorPosX(style.windowPadding.x + availReg.x/2 - buttSize/2)
      igSetNextItemWidth(buttSize)
      if igInputTextWithHint("##input", "Port name", textBuf[0].addr, 256):
        currentText = $cstring(textBuf[0].addr)
        currentText = currentText.strip()
        isChanged = true

      if not isFlatpak or not useFlatpak:
        igSetCursorPosX(style.windowPadding.x + availReg.x/2 - buttSize/2)
        if igButton(foldText & "##99999", ImVec2(x: buttSize, y: 0)):
          selectedPortExec = openFileDialog("Select executable", getCurrentDir() / "\0", when defined(windows): ["*.exe"] else: ["*"])
          isChanged = true
      else:
        when defined(linux):
          if useFlatpak:
            igSetCursorPosX(style.windowPadding.x + availReg.x/2 - buttSize/2)
            igSetNextItemWidth(buttSize)
            discard igCombo("##Flatpak99999", comboIndexFlatpak.addr, flatpakListCSTRING[0].addr, flatpakListCSTRING.len.int32, -1)
        else:
          discard #fallback


      igCalcTextSizeNonUDT(textSize.addr, "Commands preset:", nil, false, -1.0)
      igGetContentRegionAvailNonUDT(availReg.addr)
      igSetCursorPosX(style.windowPadding.x + availReg.x/2 - (textSize.x + style.itemSpacing.x + availReg.x/3) / 2)
      igAlignTextToFramePadding()
      igText("Commands preset:")
      if igIsItemHovered():
        igBeginTooltip()
        for el in 0 .. iwadBehavOptionsExpl.high:
          igText(iwadBehavOptionsExpl[el])
        igEndTooltip()
      igSameLine()
      igSetNextItemWidth(availReg.x/3)
      discard igCombo("##99998", comboIndexIWADBehav.addr, iwadBehavOptionsCSTRING[0].addr, iwadBehavOptionsCSTRING.len.int32, -1)

      igCalcTextSizeNonUDT(textSize.addr, "Extra formats:    ", nil, false, -1.0)
      igGetContentRegionAvailNonUDT(availReg.addr)
      igSetCursorPosX(style.windowPadding.x + availReg.x/2 - (textSize.x + style.itemSpacing.x) / 2)
      igAlignTextToFramePadding()
      igText("Extra formats:")
      if igIsItemHovered():
        igSetTooltip("Allow formats like .pk3 and .pk7")
      igSameLine()
      igCheckbox("##extraformats", allowExtraFormats.addr)

      when defined(linux):
        if isFlatpak:
          igCalcTextSizeNonUDT(textSize.addr, "Flatpak:    ", nil, false, -1.0)
          igGetContentRegionAvailNonUDT(availReg.addr)
          igSetCursorPosX(style.windowPadding.x + availReg.x/2 - (textSize.x + style.itemSpacing.x) / 2)
          igAlignTextToFramePadding()
          igText("Flatpak:")
          igSameLine()
          if igCheckbox("##useFlatpak", useFlatpak.addr):
            isChanged = true


      if isChanged:
        if isExecutable(selectedPortExec) and not useFlatpak:
          canAddPort = true
        elif isFlatpak and useFlatpak:
          canAddPort = true
        else:
          canAddPort = false
        if canAddPort and currentText.len > 0:
          for n in 0 .. state.ports.high:
            if currentText == state.ports[n].name:
              canAddPort = false
        else:
          canAddPort = false
        isChanged = false
      if not isFlatpak:
        igText("")
      igText("")
      igBeginDisabled(not canAddPort)
      igSetCursorPosX(style.windowPadding.x + availReg.x/2 - (buttSize/2))
      if igButton("Add", ImVec2(x: buttSize, y: itemHeight * 1.25f)):
        var pathToAdd: string
        pathToAdd = selectedPortExec
        when defined(linux):
          if isFlatpak and useFlatpak:
            pathToAdd = "%#%!" & $flatpakListCSTRING[comboIndexFlatpak]
        state.ports.add(SourcePort(name: currentText, path: pathToAdd, iwadBehav: comboIndexIWADBehav, allowExtraFormats: allowExtraFormats))
        state.selectedPort = state.ports.high
        showAddPortModal = false
        currentText = ""
        textBuf[0] = '\0'
        confCommandsTextBuf[0] = '\0'
        iwadList = walkSelectedDir(state.defaultIWADDirectory, if state.ports[state.selectedPort].allowExtraFormats: allExtensions else: @[".wad"])
        pwadList = walkSelectedDir(state.defaultPWADDirectory, if state.ports[state.selectedPort].allowExtraFormats: allExtensions else: @[".wad"])

      igEndDisabled()
      igEndPopup()

#----------------------------------------------------

    var shouldConfig: int = -1
    igGetContentRegionAvailNonUDT(leftWindowAvailSize.addr)
    igBeginChild("", ImVec2(x: 0, y: leftWindowAvailSize.y - itemHeight - (style.itemSpacing.y * 2)), false, if leftWindowHovered: ImGuiWindowFlags.None else: ImGuiWindowFlags.NoScrollBar)
    igSeparator()
    for n in 0 .. state.ports.high:                  #populating
      let item = state.ports[n]
      igPushID($item.name)
      if igSelectable(" " & $item.name, state.selectedPort == n, ImGuiSelectableFlags.None, ImVec2(x: 0, y: itemHeight * 1.25f)):
        state.selectedPort = n

      iwadList = walkSelectedDir(state.defaultIWADDirectory, if state.ports[state.selectedPort].allowExtraFormats: allExtensions else: @[".wad"])
      pwadList = walkSelectedDir(state.defaultPWADDirectory, if state.ports[state.selectedPort].allowExtraFormats: allExtensions else: @[".wad"])

      if igBeginPopupContextItem("##portSettings", ImGuiPopupFlags.MouseButtonRight):
        if igButton("Configure"):
          shouldConfig = n
          igCloseCurrentPopup()

        igEndPopup()

      if igIsItemActive() and not igIsItemHovered():    #rearrangement for igSelectable
        var delta: ImVec2
        igGetMouseDragDeltaNonUDT(delta.addr, ImGuiMouseButton(0), -1.0)
        let nNext = n + (if delta.y < 0.0: -1 else: 1)
        if nNext >= 0 and nNext < state.ports.len:
          swap(state.ports[n], state.ports[nNext])
          if state.selectedPort == n:
              state.selectedPort = nNext
          elif state.selectedPort == nNext:
              state.selectedPort = n
          igResetMouseDragDelta(ImGuiMouseButton(0))
      igPopID()

    igEndChild()
    igSeparator()

    if shouldConfig >= 0:
      configuredPort = shouldConfig
      igOpenPopup("Configure port##2000")
      showPortConfigModal = true
      canSaveConfPort = true
      selectedPortExec = state.ports[shouldConfig].path
      currentText = ""
      textBuf[0] = '\0'
      allowExtraFormats = state.ports[shouldConfig].allowExtraFormats
      comboIndexIWADBehav = state.ports[shouldConfig].iwadBehav
      when defined(linux):
        if selectedPortExec.startsWith("%#%!"):
          var indx: int32 = flatpakListCSTRING.find(selectedPortExec.split('!', 1)[1]).int32
          if indx > -1:
            comboIndexFlatpak = indx
          else:
            comboIndexFlatpak = 0
        else:
          comboIndexFlatpak = 0
      wantToDeletePort = false


    if igButton("Settings", ImVec2(x: leftWindowAvailSize.x, y: 0)) or isFirstLaunch:
      igOpenPopup("Settings###1000")
      showSettingsModal = true
      if not isFirstLaunch:
        showAbout = false
        if state.defaultIWADDirectory.len > 0:
          selectedFoldIWAD = state.defaultIWADDirectory
        else:
          selectedFoldIWAD = ""
        if state.defaultPWADDirectory.len > 0:
          selectedFoldPWAD = state.defaultPWADDirectory
        else:
          selectedFoldPWAD = ""


#----------------------------------------------------
#-------------- Settings popup begin ----------------
#----------------------------------------------------

    igSetNextWindowSize(ImVec2(x: viewport.size.x / 2, y: viewport.size.y / 1.5f), ImGuiCond.Appearing)
    igSetNextWindowPos(windowCenter, ImGuiCond.Appearing, ImVec2(x: 0.5f, y: 0.5f))
    if igBeginPopupModal(if not showAbout: "Settings###1000" else: "About###1000", if not isFirstLaunch: showSettingsModal.addr else: nil, ImGuiWindowFlags.NoResize):
      if igIsKeyPressed(256, false):    #for some reason nimgl bindings don't work, so 256 = Escape
        if not showAbout and not isFirstLaunch:
          showSettingsModal = false
        else:
          showAbout = false

      igSeparator()
      var textSize: ImVec2
      var availReg: ImVec2
      if not showAbout:
        igCalcTextSizeNonUDT(textSize.addr, "(?)", nil, false, -1.0)
        igGetContentRegionAvailNonUDT(availReg.addr)
        igSetCursorPosX(style.windowPadding.x + availReg.x - textSize.x)
        igText("(?)")
        if igIsItemHovered():
          igBeginTooltip()
          igText("Some tips:")
          igText("- right click selected port to configure it")
          igText("")
          igText("- right click selected config to rename or")
          igText("delete it")
          igText("")
          igText("- ports and configs are rearrangeable via")
          igText("holding left mouse button and dragging")
          igText("")
          igText("- items in the selected PWADs area are also")
          igText("rearrangeable - it changes order of loading")
          igText("")
          igText("- in the selected PWADs area press right mouse")
          igText("button to remove PWAD from the list")
          igText("")
          igText("- you can drag-n-drop executable into the")
          igText("left side of the main window")
          igText("")
          igText("- you can add extra PWAD that is not in the")
          igText("PWADs folder by either drag-n-dropping the file")
          igText("into the selected PWADs area or by pressing")
          igText("corresponding button")
          igEndTooltip()
        igCalcTextSizeNonUDT(textSize.addr, "Theme:", nil, false, -1.0)
        igGetContentRegionAvailNonUDT(availReg.addr)
        igSetCursorPosX(style.windowPadding.x + availReg.x/2 - (textSize.x + style.itemSpacing.x + availReg.x/2) / 2)
        igAlignTextToFramePadding()
        igText("Theme:")
        igSameLine()
        igSetNextItemWidth(availReg.x/2)
        if igCombo("##1001", state.styleIndex.addr, availStylesCSTRING[0].addr, availStylesCSTRING.len.int32, -1):
          setSelectedStyle(state.styleIndex)
        igText("")
        var iwadButtText: string
        var pwadButtText: string
        if selectedFoldIWAD.len <= 0:
          iwadButtText = "Select"
        else:
          iwadButtText = selectedFoldIWAD
        if selectedFoldPWAD.len <= 0:
          pwadButtText = "Select"
        else:
          pwadButtText = selectedFoldPWAD
        igCalcTextSizeNonUDT(textSize.addr, "IWADs directory:", nil, false, -1.0)
        igGetContentRegionAvailNonUDT(availReg.addr)
        igSetCursorPosX(style.windowPadding.x + availReg.x/2 - (textSize.x + style.itemSpacing.x + availReg.x/3) / 2)
        igAlignTextToFramePadding()
        igText("IWADs directory:")
        igSameLine()
        if igButton(extractFilename(iwadButtText) & "##8000", ImVec2(x: availReg.x/3, y: 0)):
          selectedFoldIWAD = selectFolderDialog("Select directory with IWADs", getCurrentDir())
          if selectedFoldIWAD.len > 0:
            selectedFoldIWAD = fixFold(selectedFoldIWAD)
        igCalcTextSizeNonUDT(textSize.addr, "PWADs directory:", nil, false, -1.0)
        igGetContentRegionAvailNonUDT(availReg.addr)
        igSetCursorPosX(style.windowPadding.x + availReg.x/2 - (textSize.x + style.itemSpacing.x + availReg.x/3) / 2)
        igAlignTextToFramePadding()
        igText("PWADs directory:")
        igSameLine()
        if igButton(extractFilename(pwadButtText) & "##8001", ImVec2(x: availReg.x/3, y: 0)):
          selectedFoldPWAD = selectFolderDialog("Select directory with PWADs", getCurrentDir())
          if selectedFoldPWAD.len > 0:
            selectedFoldPWAD = fixFold(selectedFoldPWAD)


        igText("")
        igCalcTextSizeNonUDT(textSize.addr, "Try to make ports execs portable:    ", nil, false, -1.0) #idk what checkbox size is so spaces work just fine
        igGetContentRegionAvailNonUDT(availReg.addr)
        igSetCursorPosX(style.windowPadding.x + availReg.x/2 - (textSize.x + style.itemSpacing.x) / 2)
        igAlignTextToFramePadding()
        igText("Try to make ports execs portable:")
        if igIsItemHovered():
          igSetTooltip("Use .home folder near executable")
        igSameLine()
        igCheckbox("##8002", doPortable.addr)

        igCalcTextSizeNonUDT(textSize.addr, "Close on launch:    ", nil, false, -1.0) #idk what checkbox size is so spaces work just fine
        igGetContentRegionAvailNonUDT(availReg.addr)
        igSetCursorPosX(style.windowPadding.x + availReg.x/2 - (textSize.x + style.itemSpacing.x) / 2)
        igAlignTextToFramePadding()
        igText("Close on launch:")
        if igIsItemHovered():
          igSetTooltip("Close this launcher when the port is running")
        igSameLine()
        igCheckbox("##8003", closeOnLaunch.addr)

        igText("")
        igText("")
        igBeginDisabled(selectedFoldIWAD.len <= 0 or selectedFoldPWAD.len <= 0)
        igSetCursorPosX(style.windowPadding.x + availReg.x/2 - (availReg.x/2.5f)/2)
        if igButton("Save##8004", ImVec2(x: availReg.x/2.5f, y: itemHeight * 1.25f)):
          state.defaultIWADDirectory = selectedFoldIWAD
          state.defaultPWADDirectory = selectedFoldPWAD
          state.doPortable = doPortable
          state.closeOnLaunch = closeOnLaunch
          if state.ports.len > 0:
            iwadList = walkSelectedDir(state.defaultIWADDirectory, if state.ports[state.selectedPort].allowExtraFormats: allExtensions else: @[".wad"])
            pwadList = walkSelectedDir(state.defaultPWADDirectory, if state.ports[state.selectedPort].allowExtraFormats: allExtensions else: @[".wad"])
          showSettingsModal = false
          if isFirstLaunch:
            isFirstLaunch = false
            igCloseCurrentPopup()
        igEndDisabled()
        igText("")
        igSeparator()
        igSetCursorPosX(style.windowPadding.x + availReg.x/2 - (availReg.x/3)/2)
        if igButton("About", ImVec2(x: availReg.x/3, y: itemHeight * 0.95f)):
          showAbout = true
        igSeparator()
      else:
        var availRegChild: ImVec2
        igGetContentRegionAvailNonUDT(availReg.addr)
        igText("")
        igText("")
        igCalcTextSizeNonUDT(textSize.addr, "Created by: much obliged", nil, false, -1.0)
        igSetCursorPosX(style.windowPadding.x + availReg.x/2 - textSize.x / 2)
        igText("Created by: ")
        igSameLine()
        hyperlink("much obliged", "https://github.com/muchobliged")
        igText("")
        igText("")
        igCalcTextSizeNonUDT(textSize.addr, "Extra credits:", nil, false, -1.0)
        igSetCursorPosX(style.windowPadding.x + availReg.x/2 - textSize.x / 2)
        igText("Extra credits:")
        igSetCursorPosX(style.windowPadding.x + availReg.x/2 - (availReg.x/1.5f) / 2)
        igBeginChild("AboutCreditsUp", ImVec2(x: availReg.x/1.5f, y: availReg.y/4))
        igGetContentRegionAvailNonUDT(availRegChild.addr)
        igSeparator()
        hyperlink("Imariscal", "https://github.com/lmariscal")
        igSameLine()
        igCalcTextSizeNonUDT(textSize.addr, "NimGL/ImGui", nil, false, -1.0)
        igSetCursorPosX(availRegChild.x - textSize.x)
        hyperlink("NimGL/ImGui", "https://github.com/nimgl/nimgl")
        hyperlink("Patitotective", "https://github.com/Patitotective")
        igSameLine()
        igCalcTextSizeNonUDT(textSize.addr, "tinydialogs", nil, false, -1.0)
        igSetCursorPosX(availRegChild.x - textSize.x)
        hyperlink("tinydialogs", "https://github.com/Patitotective/tinydialogs")
        hyperlink("TheAncientOwl", "https://github.com/TheAncientOwl")
        igSameLine()
        igCalcTextSizeNonUDT(textSize.addr, "some themes", nil, false, -1.0)
        igSetCursorPosX(availRegChild.x - textSize.x)
        hyperlink("some themes", "https://github.com/ocornut/imgui/issues/707")
        igSeparator()
        igEndChild()
        igText("")
        igCalcTextSizeNonUDT(textSize.addr, version, nil, false, -1.0)
        igSetCursorPosX(style.windowPadding.x + availReg.x/2 - textSize.x / 2)
        igText(version)
        igSetCursorPosY(availReg.y)
        igSetCursorPosX(style.windowPadding.x + availReg.x/2 - (availReg.x/2)/2)
        if igButton("Back", ImVec2(x: availReg.x/2f, y: itemHeight * 1.25f)):
          showAbout = false
      igEndPopup()


#----------------------------------------------------


#----------------------------------------------------
#------------ Configure port popup begin ------------
#----------------------------------------------------

    igSetNextWindowSize(ImVec2(x: viewport.size.x / 2, y: viewport.size.y / 1.5f), ImGuiCond.Appearing)
    igSetNextWindowPos(windowCenter, ImGuiCond.Appearing, ImVec2(x: 0.5f, y: 0.5f))
    if igBeginPopupModal("Configure port##2000", showPortConfigModal.addr, ImGuiWindowFlags.NoResize):
      if igIsKeyPressed(256, false):          #for some reason nimgl bindings don't work, so 256 = Escape
        if not wantToDeletePort:
          showPortConfigModal = false
        else:
          wantToDeletePort = false

      var isThisFlatpak: bool = false

      when defined(linux):
        isThisFlatpak = if selectedPortExec.startsWith("%#%!"): true else: false
        if isThisFlatpak and not isFlatpak:
          canSaveConfPort = false

      var isChanged: bool = false
      igSeparator()
      igText("")
      var availReg: ImVec2
      igGetContentRegionAvailNonUDT(availReg.addr)
      var textSize: ImVec2
      var foldText: string
      if not wantToDeletePort:

        foldText = "Select executable"
        if not isThisFlatpak:
          if isExecutable(selectedPortExec):
            foldText = extractFilename(selectedPortExec)


        var buttSize = availReg.x/1.5f

        igSetCursorPosX(style.windowPadding.x + availReg.x/2 - buttSize/2)
        igSetNextItemWidth(buttSize)
        if igInputTextWithHint("##input", state.ports[configuredPort].name, textBuf[0].addr, 256):
          canSaveConfPort = true
          currentText = $cstring(textBuf[0].addr)
          currentText = currentText.strip()
          isChanged = true
        if currentText.len <= 0:
          currentText = state.ports[configuredPort].name

        if not isThisFlatpak:
          igSetCursorPosX(style.windowPadding.x + availReg.x/2 - buttSize/2)
          if igButton(foldText & "##selectexec", ImVec2(x: buttSize, y: 0)):
            selectedPortExec = openFileDialog("Select executable", getCurrentDir() / "\0", when defined(windows): ["*.exe"] else: ["*"])
            isChanged = true
        else:
          when defined(linux):
            igSetCursorPosX(style.windowPadding.x + availReg.x/2 - buttSize/2)
            igSetNextItemWidth(buttSize)
            discard igCombo("##Flatpak99999", comboIndexFlatpak.addr, flatpakListCSTRING[0].addr, flatpakListCSTRING.len.int32, -1)
          else:
            discard #fallback



        igCalcTextSizeNonUDT(textSize.addr, "Commands preset:", nil, false, -1.0)
        igGetContentRegionAvailNonUDT(availReg.addr)
        igSetCursorPosX(style.windowPadding.x + availReg.x/2 - (textSize.x + style.itemSpacing.x + availReg.x/3) / 2)
        igAlignTextToFramePadding()
        igText("Commands preset:")
        if igIsItemHovered():
          igBeginTooltip()
          for el in 0 .. iwadBehavOptionsExpl.high:
            igText(iwadBehavOptionsExpl[el])
          igEndTooltip()
        igSameLine()
        igSetNextItemWidth(availReg.x/3)
        discard igCombo("##99998", comboIndexIWADBehav.addr, iwadBehavOptionsCSTRING[0].addr, iwadBehavOptionsCSTRING.len.int32, -1)


        igCalcTextSizeNonUDT(textSize.addr, "Extra formats:    ", nil, false, -1.0)
        igGetContentRegionAvailNonUDT(availReg.addr)
        igSetCursorPosX(style.windowPadding.x + availReg.x/2 - (textSize.x + style.itemSpacing.x) / 2)
        igAlignTextToFramePadding()
        igText("Extra formats:")
        if igIsItemHovered():
          igSetTooltip("Allow formats like .pk3 and .pk7")
        igSameLine()
        igCheckbox("##extraformats", allowExtraFormats.addr)

        igText("")
        igText("")

        if isChanged:
          canSaveConfPort = true
          if not isThisFlatpak:
            if isExecutable(selectedPortExec):
              canSaveConfPort = true
            else:
              canSaveConfPort = false

          if canSaveConfPort and currentText.len > 0:
            for n in 0 .. state.ports.high:
              if currentText == state.ports[n].name and n != configuredPort:
                canSaveConfPort = false
          else:
            canSaveConfPort = false
          isChanged = false

        igBeginDisabled(not canSaveConfPort or (isThisFlatpak and not isFlatpak))
        igSetCursorPosX(style.windowPadding.x + availReg.x/2 - buttSize/2)
        if igButton("Save", ImVec2(x: buttSize, y: itemHeight * 1.25f)):
          state.ports[configuredPort].name = currentText
          if not isThisFlatpak:
            state.ports[configuredPort].path = selectedPortExec
          else:
            discard #fallback
            when defined(linux):
              state.ports[configuredPort].path = "%#%!" & $flatpakListCSTRING[comboIndexFlatpak]
          state.ports[configuredPort].allowExtraFormats = allowExtraFormats
          state.ports[configuredPort].iwadBehav = comboIndexIWADBehav
          iwadList = walkSelectedDir(state.defaultIWADDirectory, if state.ports[state.selectedPort].allowExtraFormats: allExtensions else: @[".wad"])
          pwadList = walkSelectedDir(state.defaultPWADDirectory, if state.ports[state.selectedPort].allowExtraFormats: allExtensions else: @[".wad"])
          showPortConfigModal = false
          if not allowExtraFormats:
            removeUnsupportedPWADs(configuredPort)
        igEndDisabled()
        igText("")
        igText("")
        igText("")
        igText("")
        igSeparator()

        igGetContentRegionAvailNonUDT(availReg.addr)
        igSetCursorPosY(viewport.size.y / 1.5f - style.windowPadding.y - availReg.y/2 - (availReg.y / 1.5f) / 2)
        igSetCursorPosX(style.windowPadding.x + availReg.x/2 - (availReg.x / 2) / 2)
        if igButton("Remove port", ImVec2(x: availReg.x / 2, y: availReg.y / 1.5f)):
          wantToDeletePort = true
      else:
        igText("")
        igText("")
        igText("")
        var warningText: string = "Remove selected port and all related configs?"
        var warningText1: string = "Are you sure?"
        igCalcTextSizeNonUDT(textSize.addr, warningText, nil, false, -1.0)
        igSetCursorPosX(style.windowPadding.x + availReg.x/2 - (textSize.x) / 2)
        igAlignTextToFramePadding()
        igText(warningText)
        igCalcTextSizeNonUDT(textSize.addr, warningText1, nil, false, -1.0)
        igSetCursorPosX(style.windowPadding.x + availReg.x/2 - (textSize.x) / 2)
        igAlignTextToFramePadding()
        igText(warningText1)
        igText("")
        igSetCursorPosX(style.windowPadding.x + availReg.x/2 - (availReg.x / 3 + style.itemSpacing.x + availReg.x / 3) / 2)
        if igButton("Yes##12345", ImVec2(x: availReg.x / 3, y: 0)):
          wantToDeletePort = false
          showPortConfigModal = false
          deletePort(configuredPort)
        igSameLine()
        if igButton("No##01234", ImVec2(x: availReg.x / 3, y: 0)):
          wantToDeletePort = false

      igEndPopup()

#----------------------------------------------------

    igEnd()




#----------------------------------------------------
#-------------- right main window begin -------------
#----------------------------------------------------


    igSetNextWindowPos(ImVec2(x: state.leftWindowWidth, y: 0), ImGuiCond.Always, ImVec2(x: 0, y: 0))
    igSetNextWindowSize(ImVec2(x: viewport.size.x - state.leftWindowWidth, y: viewport.size.y), ImGuiCond.Always)

    igBegin("##2", nil, mainFlags2) #right(main) window - begin

    if state.ports.len > 0:
#----------------------------------------------------
#---------------- tabs system begin -----------------
#----------------------------------------------------
      igGetContentRegionAvailNonUDT(rightWindowAvailSize.addr)
      igBeginChild("Tabs", ImVec2(x: rightWindowAvailSize.x, y: itemHeight * 1.25f + style.itemSpacing.y * 2), false, ImGuiWindowFlags.HorizontalScrollbar)
      var availReg: ImVec2
      igGetContentRegionAvailNonUDT(availReg.addr)
      style.selectableTextAlign = ImVec2(x: 0.5f, y: 0.5f)
      var shouldDeleteTab = -1
      var shouldAddTab = false
      var shouldRenameConf = false
      if igSelectable("  +  ", false, ImGuiSelectableFlags.None, ImVec2(x: availReg.x/20, y: itemHeight)):
        shouldAddTab = true
      var port = addr(state.ports[state.selectedPort])
      if port.configs.len > 0:
        var confs = addr(state.ports[state.selectedPort].configs)
        for i in 0 .. confs[].high:                         #populating tabs
          var tab = confs[i]
          igPushID($tab.name)
          igSameLine()
          if igSelectable(tab.name, port.selectedConfig == i, ImGuiSelectableFlags.None, ImVec2(x: availReg.x/5, y: itemHeight)):
            port.selectedConfig = i
            iwadList = walkSelectedDir(state.defaultIWADDirectory, if port.allowExtraFormats: allExtensions else: @[".wad"])
            pwadList = walkSelectedDir(state.defaultPWADDirectory, if port.allowExtraFormats: allExtensions else: @[".wad"])

          if igBeginPopupContextItem($tab.name & "##tabDeletePopUp", ImGuiPopupFlags.MouseButtonRight):

            if igButton("Rename"):
              shouldRenameConf = true
              igCloseCurrentPopup()

            if igButton("Delete"):
              shouldDeleteTab = i
              igCloseCurrentPopup()

            igEndPopup()

          if igIsItemActive() and not igIsItemHovered():    #rearrangement for igSelectable
            var delta: ImVec2
            igGetMouseDragDeltaNonUDT(delta.addr, ImGuiMouseButton(0), -1.0)
            let iNext = i + (if delta.x < 0.0: -1 else: 1)
            if iNext >= 0 and iNext < confs[].len:
              swap(confs[i], confs[iNext])
              if port.selectedConfig == i:
                  port.selectedConfig = iNext
              elif port.selectedConfig == iNext:
                  port.selectedConfig = i
              igResetMouseDragDelta(ImGuiMouseButton(0))

          igPopID()

        if shouldDeleteTab >= 0:
          deleteConf(state.selectedPort, shouldDeleteTab)


      if shouldAddTab:
        var numb: int = 0
        var confName: string
        var nameOk: bool = false

        while not nameOk:
          nameOk = true
          numb += 1
          confName = $(state.ports[state.selectedPort].configs.len + numb)
          for i in 0 .. state.ports[state.selectedPort].configs.high:
            if $confName == $state.ports[state.selectedPort].configs[i].name:
              nameOk = false
              break


        state.ports[state.selectedPort].configs.insert(PortConfig(name: $confName), 0)
        port.selectedConfig = 0

      style.selectableTextAlign = ImVec2(x: 0, y: 0.5f)

      igSeparator()
      igEndChild()

      if shouldRenameConf:
        showConfRenameModal = true
        textBuf[0] = '\0'
        currentText = ""
        igOpenPopup("Configuration rename##91111")

#----------------------------------------------------
#------------ Rename tab(conf) popup begin ----------
#----------------------------------------------------


      igSetNextWindowSize(ImVec2(x: viewport.size.x / 3, y: viewport.size.y / 3), ImGuiCond.Appearing)
      igSetNextWindowPos(windowCenter, ImGuiCond.Appearing, ImVec2(x: 0.5f, y: 0.5f))
      if igBeginPopupModal("Configuration rename##91111", showConfRenameModal.addr, ImGuiWindowFlags.NoResize):
        if igIsKeyPressed(256, false):          #for some reason nimgl bindings don't work, so 256 = Escape
          showConfRenameModal = false
        var otherConfs = addr(state.ports[state.selectedPort].configs)
        var selConf = addr(state.ports[state.selectedPort].configs[state.ports[state.selectedPort].selectedConfig])
        var isNameGood: bool = true
        igSeparator()
        igText("")
        var availReg: ImVec2
        igGetContentRegionAvailNonUDT(availReg.addr)
        var buttSize = availReg.x / 2
        igSetCursorPosX(style.windowPadding.x + availReg.x/2 - buttSize/2)
        igSetNextItemWidth(buttSize)
        if igInputTextWithHint("##confNameInput", $selConf.name, textBuf[0].addr, 256):
          currentText = $cstring(textBuf[0].addr)
          currentText = currentText.strip()

        if isNameGood:
          for i in 0 .. otherConfs[].high:
            if currentText == otherConfs[i].name:
              isNameGood = false
              break

        igText("")
        igBeginDisabled(not isNameGood or currentText.len <= 0)
        igSetCursorPosX(style.windowPadding.x + availReg.x/2 - (buttSize/2))
        if igButton("Save##434343", ImVec2(x: buttSize, y: itemHeight * 1.25f)):
          selConf.name = currentText
          showConfRenameModal = false
        igEndDisabled()
        igEndPopup()

#----------------------------------------------------
#---------------- tabs content begin ----------------
#----------------------------------------------------

      if port.configs.len > 0:
        var canPlay: bool = true
        var availRegTabs: ImVec2
        style.selectableTextAlign = ImVec2(x: 0.5f, y: 0.5f)
        var conf = addr(state.ports[state.selectedPort].configs[state.ports[state.selectedPort].selectedConfig])
        var textSize: ImVec2
        if $cstring(confCommandsTextBuf[0].addr) != conf.commands:
          setBuffer(confCommandsTextBuf, $conf.commands)

        igGetContentRegionAvailNonUDT(rightWindowAvailSize.addr)
        igBeginChild("TabsContent", ImVec2(x: rightWindowAvailSize.x, y: rightWindowAvailSize.y))
        igGetContentRegionAvailNonUDT(availRegTabs.addr)
        var buttSize = availRegTabs.x/2
        igText("")
        igCalcTextSizeNonUDT(textSize.addr, "IWAD", nil, false, -1.0)
        igSetCursorPosX(availRegTabs.x/2 - (textSize.x) / 2)
        igText("IWAD")
        igSetCursorPosX(availRegTabs.x/2 - (availRegTabs.x / 2) / 2)
        igBeginListBox("##IWAD ListBox", ImVec2(x: if iwadList.len < 3: buttSize else: buttSize + style.scrollbarSize, y: itemHeight * 2.25f))
        if iwadList.len > 0:
          for j in 0 .. iwadList.high:
            igPushID(iwadList[j])
            if igSelectable(extractFilename(iwadList[j]), conf.iwad == iwadList[j]):
              conf.iwad = iwadList[j]
            igPopID()
        else:
          canPlay = false
          igSeparator()
          discard igSelectable("IWADs not found!", false)

          if igIsItemHovered():
            igSetTooltip("Select proper IWADs directory in settings")

          igSeparator()
        igEndListBox()
        igText("")
        igCalcTextSizeNonUDT(textSize.addr, "PWAD", nil, false, -1.0)
        igSetCursorPosX(availRegTabs.x/2 - (textSize.x) / 2)
        igText("PWADs")


        buttSize = availRegTabs.x/3
        var butt1Size = availRegTabs.x/3
        if conf.pwads.len >= 9:
          buttSize += style.scrollbarSize
        if pwadList.len >= 10:
          butt1Size += style.scrollbarSize

        var shouldRemovePWAD = -1
        var shouldAddPWAD = -1
        var customWAD = ""
        igSetCursorPosX(availRegTabs.x/2 - (buttSize + butt1Size/1.5f + style.itemSpacing.x) / 2)
        igBeginListBox("##PWADs selected ListBox", ImVec2(x: buttSize, y: itemHeight * 8))
        for j in 0 .. conf.pwads.high:
          igPushID(conf.pwads[j] & "##selectedPWAD")

          discard igSelectable(extractFilename(conf.pwads[j]), false)

          if igIsItemClicked(ImGuiMouseButton(1)):
            shouldRemovePWAD = j

          if igIsItemActive() and not igIsItemHovered():    #rearrangement for igSelectable
            var delta: ImVec2
            igGetMouseDragDeltaNonUDT(delta.addr, ImGuiMouseButton(0), -1.0)
            let jNext = j + (if delta.y < 0.0: -1 else: 1)
            if jNext >= 0 and jNext < conf.pwads.len:
              swap(conf.pwads[j], conf.pwads[jNext])
              igResetMouseDragDelta(ImGuiMouseButton(0))

          igPopID()
        igSeparator()
        if igSelectable("Add custom PWAD"):
          customWAD = openFileDialog("Add custom PWAD", if state.defaultPWADDirectory != "": state.defaultPWADDirectory else: getCurrentDir() / "\0", if state.ports[state.selectedPort].allowExtraFormats: allExtensionsAst else: @["*.wad"])
          if conf.pwads.contains(customWAD):
            customWAD = ""
        igSeparator()

        if shouldAddDragWAD:
          shouldAddDragWAD = false
          if igIsWindowHovered():
            if not state.ports[state.selectedPort].allowExtraFormats:
              if dragPath.toLower().endsWith(".wad"):
                customWAD = dragPath
            else:
              customWAD = dragPath
            if conf.pwads.contains(customWAD):
              customWAD = ""
        igEndListBox()

        igSameLine()
        igBeginListBox("##PWADs ListBox", ImVec2(x: butt1Size/1.5f, y: itemHeight * 8))
        if pwadList.len > 0:
          for j in 0 .. pwadList.high:
            var canAddPwad: bool = true
            for k in 0 .. conf.pwads.high:
              if pwadList[j] == conf.pwads[k]:
                canAddPwad = false
                break
            if canAddPwad:
              igPushID(pwadList[j])
              if igSelectable(extractFilename(pwadList[j])):
                shouldAddPWAD = j

              igPopID()
        else:
          igSeparator()
          discard igSelectable("PWADs not found!", false)

          if igIsItemHovered():
            igSetTooltip("Select proper PWADs directory in settings")

          igSeparator()

        igEndListBox()
        igText("")
        igCalcTextSizeNonUDT(textSize.addr, "Extra commands", nil, false, -1.0)
        igGetContentRegionAvailNonUDT(availRegTabs.addr)
        igSetCursorPosX(availRegTabs.x/2 - textSize.x / 2)
        igText("Extra commands")
        buttSize = availRegTabs.x/2
        igSetCursorPosX(availRegTabs.x/2 - buttSize / 2)
        igSetNextItemWidth(buttSize)
        if igInputTextWithHint("##inputCommands", "-skill <4>", confCommandsTextBuf[0].addr, 256):
          conf.commands = $cstring(confCommandsTextBuf[0].addr)

        igSameLine()
        #igAlignTextToFramePadding()
        igText("(?)")
        if igIsItemHovered():
          igBeginTooltip()
          igText("You can pass port arguments here:")
          igText("")
          igText("-skill 4 -nosound")
          igText("")
          igText("Also you can pass program arguments. They must be")
          igText("written first and closed with ; symbol:")
          igText("")
          igText("--socket=x11 --nosocket=wayland; -skill 4 -nosound")
          igEndTooltip()
          #conf.commands = conf.commands.strip()
        #[var commandsText: string
        var commandsSeq = conf.commands.splitWhitespace()
        for i in 0 .. commandsSeq.high:
          if i < commandsSeq.high:
            commandsText &= commandsSeq[i] & " "
          else:
            commandsText &= commandsSeq[i]]#
        igText("")
        igText("")
        igBeginDisabled(not canPlay)
        buttSize = availRegTabs.x/2
        igSetCursorPosX(availRegTabs.x/2 - buttSize/2)
        if igButton(if canPlay: "Play" else: "IWADs not found!", ImVec2(x: buttSize, y: itemHeight * 2)):
          if conf.iwad.len <= 0 and iwadList.len > 0:
            conf.iwad = iwadList[0]
          runPort(state.selectedPort, state.ports[state.selectedPort].selectedConfig)
          if closeOnLaunch:
            w.setWindowShouldClose(true)
        igEndDisabled()

        if shouldRemovePWAD >= 0:
          conf.pwads.delete(shouldRemovePWAD)
        if shouldAddPWAD >= 0:
          conf.pwads.add(pwadList[shouldAddPWAD])
        if customWAD != "":
          conf.pwads.add(customWAD)
        igEndChild()

        style.selectableTextAlign = ImVec2(x: 0, y: 0.5f)
#----------------------------------------------------

    igEnd()                         #right(main) window - end




    igRender()
    glClearColor(0.45f, 0.55f, 0.60f, 1.00f)
    glClear(GL_COLOR_BUFFER_BIT)

    igOpenGL3RenderDrawData(igGetDrawData())

    w.swapBuffers()

  if w.windowShouldClose:
    saveConfig()

  igOpenGL3Shutdown()
  igGlfwShutdown()
  context.igDestroyContext()

  w.destroyWindow()
  glfwTerminate()

main()
