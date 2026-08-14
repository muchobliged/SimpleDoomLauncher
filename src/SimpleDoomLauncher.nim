import backgroundlogic, extraStyles, translation
import std/[strutils, os, osproc, threadpool]
import nimgl/[opengl, glfw], nimgl/imgui, nimgl/imgui/[impl_opengl, impl_glfw]
import tinydialogs


#TODO     Flatpak build?            Compile to C?


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

#let TargetFPS = 60.0
let BackgroundFPS = 10.0
proc fpsLimit(win: GLFWWindow) =
  var lastFrameTime = glfwGetTime()
  let focused = win.getWindowAttrib(GLFWFocused) == GLFW_TRUE
  let hovered = win.getWindowAttrib(GLFWHovered) == GLFW_TRUE
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
const fontRawData = staticRead("../assets/ProggyClean_Extra.ttf")

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
var shouldAddZDL: bool = false
var shouldImportTab: bool = false
var dragPath: string = ""


var fontConfig: ImFontConfig
var newFont: ptr ImFont


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

  fontConfig.fontDataOwnedByAtlas = false

  let newFont = io.fonts.addFontFromMemoryTTF(cast[pointer](fontRawData.cstring), fontRawData.len.int32, 13.0, addr fontConfig, io.fonts.getGlyphRangesCyrillic())

  io.fonts.build()




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

      if path.toLower().endsWith(".zdl"):
        shouldAddZDL = true
        dragPath = path
      elif path.toLower().endsWith(".sdl_cfg"):
        var cfg: PortConfig
        cfg = importConfig(path)
        bufferConfigImport = cfg
        shouldImportTab = true
      elif ifExtensionCorrect(path):
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
  setLang(state.lang)

  var iwadList: seq[string]
  var pwadList: seq[string]
  var currentText: string
  var canAddPort: bool = false
  var wantToDeletePort: bool = false
  var showAbout: bool = false
  var canSaveConfPort: bool = true
  var allowExtraFormats: bool = true
  var useFlatpak: bool = false
  var doPortable: bool = true
  var closeOnLaunch: bool = state.closeOnLaunch
  var checkForUpdates: bool = state.checkForUpdates
  var didCheckForUpdates: bool = false
  var selectedFoldIWAD: string = ""
  var selectedFoldPWAD: string = ""
  var comboIndexIWADBehav: int32 = 0
  var comboIndexFlatpak: int32 = 0
  var showAddPortModal: bool = false
  var showConfRenameModal: bool = true
  var showConfDeleteModal: bool = true
  var showSettingsModal: bool = true
  var showPortConfigModal: bool = true
  var selectedPortExec: string = ""
  var configuredPort: int = -1
  var shouldPasteConfig: bool = false
  var shouldOpenSettings: bool = false
  var wasFocused: bool = true


  proc updateWADsLists() =
    if state.ports.len > 0:
      iwadList = walkSelectedDir(state.defaultIWADDirectory, if state.ports[state.selectedPort].allowExtraFormats: allExtensions else: @[".wad"])
      pwadList = walkSelectedDir(state.defaultPWADDirectory, if state.ports[state.selectedPort].allowExtraFormats: allExtensions else: @[".wad"])

  updateWADsLists()



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
      ImVec2(x: 5, y: 0),
      ImVec2(x: viewport.size.x, y: viewport.size.y),
      false
      )                       #hack to make left window resizable only from right border

    var leftWindowAvailSize: ImVec2
    var rightWindowAvailSize: ImVec2
    glfwPollEvents()
    igOpenGL3NewFrame()
    igGlfwNewFrame()
    igNewFrame()

    if w.getWindowAttrib(GLFWFocused) == GLFW_FALSE:
      wasFocused = true
    elif wasFocused:
      updateWADsLists()
      wasFocused = false


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

    if state.checkForUpdates and not didCheckForUpdates and not isFirstLaunch:
      didCheckForUpdates = true
      spawn getLatestAppVersion()

    if showUpdateModal:
      igOpenPopup("###Update Popup")

#----------------------------------------------------
#--------------- Update popup begin -----------------
#----------------------------------------------------


    igSetNextWindowSize(ImVec2(x: viewport.size.x / 2.5f, y: viewport.size.y / 3), ImGuiCond.Appearing)
    igSetNextWindowPos(windowCenter, ImGuiCond.Appearing, ImVec2(x: 0.5f, y: 0.5f))
    if igBeginPopupModal(trans.updateFound[0] & "###Update Popup", showUpdateModal.addr, cast[ImGuiWindowFlags](ImGuiWindowFlags.NoResize.int)):
      if igIsKeyPressed(256, false):          #for some reason nimgl bindings don't work, so 256 = Escape
        showUpdateModal = false
      igSeparator()
      var availReg: ImVec2
      var textSize: ImVec2
      var updVersions: string = "v" & $version & " --> v" & $latestVersion
      igGetContentRegionAvailNonUDT(availReg.addr)
      igText("")
      igCalcTextSizeNonUDT(textSize.addr, updVersions, nil, false, -1.0)
      igSetCursorPosX(style.windowPadding.x + availReg.x/2 - textSize.x/2)
      igText(updVersions)
      igText("")

      igCalcTextSizeNonUDT(textSize.addr, trans.updateFound[1], nil, false, -1.0)
      igSetCursorPosX(style.windowPadding.x + availReg.x/2 - textSize.x/2)
      igText(trans.updateFound[1])

      igText("")

      igSetCursorPosX(style.windowPadding.x + availReg.x/2 - (availReg.x / 3 + style.itemSpacing.x + availReg.x / 3) / 2)
      if igButton(trans.no & "##01234", ImVec2(x: availReg.x / 3, y: 0)):
        showUpdateModal = false
      igSameLine()
      if igButton(trans.yes & "##12345", ImVec2(x: availReg.x / 3, y: 0)):
        openGitHub()
        showUpdateModal = false

      igEndPopup()

#----------------------------------------------------


    if shouldOpenAddPort:
      if showAddPortModal:
        selectedPortExec = dragPath           # drag into already opened AddPortModal
        shouldOpenAddPort = false
      elif not leftWindowHovered:             # allow drop-add only in left side of the window
        shouldOpenAddPort = false
    if igButton(trans.addport & "###Add Port Button", ImVec2(x: leftWindowAvailSize.x, y: 0)) or shouldOpenAddPort:
      igOpenPopup("###Add Port Popup")
      showAddPortModal = true
      selectedPortExec = ""
      currentText = ""
      textBuf[0] = '\0'
      allowExtraFormats = true
      canAddPort = false
      comboIndexIWADBehav = 0
      comboIndexFlatpak = 0
      doPortable = true
      when defined(linux):
        useFlatpak = false
      if shouldOpenAddPort:
        shouldOpenAddPort = false
        selectedPortExec = dragPath

#----------------------------------------------------
#-------------- Add Port popup begin ----------------
#----------------------------------------------------


    igSetNextWindowSize(ImVec2(x: viewport.size.x / 2.5f, y: viewport.size.y / 1.65f), ImGuiCond.Appearing)
    igSetNextWindowPos(windowCenter, ImGuiCond.Appearing, ImVec2(x: 0.5f, y: 0.5f))
    if igBeginPopupModal(trans.addport & "###Add Port Popup", showAddPortModal.addr, cast[ImGuiWindowFlags](ImGuiWindowFlags.NoResize.int)):
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
        foldText = trans.selectexecutable

      var buttSize = availReg.x/1.5f
      igSetCursorPosX(style.windowPadding.x + availReg.x/2 - buttSize/2)
      igSetNextItemWidth(buttSize)
      if igInputTextWithHint("##input", trans.portname, textBuf[0].addr, 256):
        currentText = $cstring(textBuf[0].addr)
        currentText = currentText.strip()
        isChanged = true

      if not isFlatpak or not useFlatpak:
        igSetCursorPosX(style.windowPadding.x + availReg.x/2 - buttSize/2)
        if igButton(foldText & "##99999", ImVec2(x: buttSize, y: 0)):
          selectedPortExec = openFileDialog(trans.selectexecutable, getCurrentDir(), when defined(windows): ["*.exe"] else: ["*"], "Executable")
          isChanged = true
      else:
        when defined(linux):
          if useFlatpak:
            igSetCursorPosX(style.windowPadding.x + availReg.x/2 - buttSize/2)
            igSetNextItemWidth(buttSize)
            discard igCombo("##Flatpak99999", comboIndexFlatpak.addr, flatpakListCSTRING[0].addr, flatpakListCSTRING.len.int32, -1)
        else:
          discard #fallback


      when defined(linux):
        if isFlatpak:
          igCalcTextSizeNonUDT(textSize.addr, "Flatpak:    ", nil, false, -1.0)
          igSetCursorPosX(style.windowPadding.x + availReg.x/2 - (textSize.x + style.itemSpacing.x) / 2)
          igAlignTextToFramePadding()
          igText("Flatpak:")
          igSameLine()
          if igCheckbox("##useFlatpak", useFlatpak.addr):
            isChanged = true


      igText("")
      igSeparator()
      igCalcTextSizeNonUDT(textSize.addr, trans.commandspreset, nil, false, -1.0)
      igSetCursorPosX(style.windowPadding.x + availReg.x/2 - (textSize.x + style.itemSpacing.x + availReg.x/3) / 2)
      igAlignTextToFramePadding()
      igText(trans.commandspreset)
      if igIsItemHovered():
        igBeginTooltip()
        for el in 0 .. iwadBehavOptionsExpl.high:
          igText(iwadBehavOptionsExpl[el])
        igEndTooltip()
      igSameLine()
      igSetNextItemWidth(availReg.x/3)
      discard igCombo("##99998", comboIndexIWADBehav.addr, iwadBehavOptionsCSTRING[0].addr, iwadBehavOptionsCSTRING.len.int32, -1)

      if not useFlatpak:
        igCalcTextSizeNonUDT(textSize.addr, trans.makeexecportable & "    ", nil, false, -1.0)
        igSetCursorPosX(style.windowPadding.x + availReg.x/2 - (textSize.x + style.itemSpacing.x) / 2)
        igAlignTextToFramePadding()
        igText(trans.makeexecportable)
        if igIsItemHovered():
          igSetTooltip(trans.makeexecportableFAQ)
        igSameLine()
        igCheckbox("##doPortable", doPortable.addr)

      igCalcTextSizeNonUDT(textSize.addr, trans.extraformats & "    ", nil, false, -1.0)
      igSetCursorPosX(style.windowPadding.x + availReg.x/2 - (textSize.x + style.itemSpacing.x) / 2)
      igAlignTextToFramePadding()
      igText(trans.extraformats)
      if igIsItemHovered():
        igSetTooltip(trans.extraformatsFAQ)
      igSameLine()
      igCheckbox("##extraformats", allowExtraFormats.addr)

      igSeparator()


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

      igSetCursorPosY(availReg.y)
      igBeginDisabled(not canAddPort)
      igSetCursorPosX(style.windowPadding.x + availReg.x/2 - (buttSize/2))
      if igButton(trans.add, ImVec2(x: buttSize, y: itemHeight * 1.25f)):
        var pathToAdd: string
        pathToAdd = selectedPortExec
        when defined(linux):
          if isFlatpak and useFlatpak:
            pathToAdd = "%#%!" & $flatpakListCSTRING[comboIndexFlatpak]
            doPortable = false
        state.ports.add(SourcePort(name: currentText, path: pathToAdd, iwadBehav: comboIndexIWADBehav, allowExtraFormats: allowExtraFormats, doPortable: doPortable))
        state.selectedPort = state.ports.high
        showAddPortModal = false
        currentText = ""
        textBuf[0] = '\0'
        confCommandsTextBuf[0] = '\0'
        updateWADsLists()

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

        updateWADsLists()

      if igBeginPopupContextItem("##portSettings", ImGuiPopupFlags.MouseButtonRight):
        if igButton(trans.configure):
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
      igOpenPopup("###Configure Port Popup")
      showPortConfigModal = true
      canSaveConfPort = true
      selectedPortExec = state.ports[shouldConfig].path
      currentText = ""
      textBuf[0] = '\0'
      allowExtraFormats = state.ports[shouldConfig].allowExtraFormats
      doPortable = state.ports[shouldConfig].doPortable
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


    if igButton(trans.settings, ImVec2(x: leftWindowAvailSize.x, y: 0)) or isFirstLaunch or shouldOpenSettings:
      igOpenPopup("###Settings")
      shouldOpenSettings = false
      showSettingsModal = true
      checkForUpdates = state.checkForUpdates
      closeOnLaunch = state.closeOnLaunch
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

    igSetNextWindowSize(ImVec2(x: viewport.size.x / 2, y: viewport.size.y / 1.35f), ImGuiCond.Appearing)
    igSetNextWindowPos(windowCenter, ImGuiCond.Appearing, ImVec2(x: 0.5f, y: 0.5f))
    if igBeginPopupModal(if not showAbout: trans.settings & "###Settings" else: trans.about & "###Settings", if not isFirstLaunch: showSettingsModal.addr else: nil, ImGuiWindowFlags.NoResize):
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
          for it in trans.tips:
            igText(it)
          igEndTooltip()

        igCalcTextSizeNonUDT(textSize.addr, trans.language, nil, false, -1.0)
        igSetCursorPosX(style.windowPadding.x + availReg.x/2 - (textSize.x + style.itemSpacing.x + availReg.x/2.5f) / 2)
        igAlignTextToFramePadding()
        igText(trans.language)
        igSameLine()
        igSetNextItemWidth(availReg.x/2.5f)
        if igCombo("###language combo", state.lang.addr, langsCSTRING[0].addr, langsCSTRING.len.int32, -1):
          setLang(state.lang)

        igCalcTextSizeNonUDT(textSize.addr, trans.theme, nil, false, -1.0)
        igSetCursorPosX(style.windowPadding.x + availReg.x/2 - (textSize.x + style.itemSpacing.x + availReg.x/2.5f) / 2)
        igAlignTextToFramePadding()
        igText(trans.theme)
        igSameLine()
        igSetNextItemWidth(availReg.x/2.5f)
        if igCombo("##1001", state.styleIndex.addr, availStylesCSTRING[0].addr, availStylesCSTRING.len.int32, -1):
          setSelectedStyle(state.styleIndex)
        igText("")
        var iwadButtText: string
        var pwadButtText: string
        if selectedFoldIWAD.len <= 0:
          iwadButtText = trans.select
        else:
          iwadButtText = selectedFoldIWAD
        if selectedFoldPWAD.len <= 0:
          pwadButtText = trans.select
        else:
          pwadButtText = selectedFoldPWAD
        igCalcTextSizeNonUDT(textSize.addr, trans.iwadsdirectory, nil, false, -1.0)
        igSetCursorPosX(style.windowPadding.x + availReg.x/2 - (textSize.x + style.itemSpacing.x + availReg.x/3) / 2)
        igAlignTextToFramePadding()
        igText(trans.iwadsdirectory)
        igSameLine()
        if igButton(extractFilename(iwadButtText) & "###select iwad dir button", ImVec2(x: availReg.x/3, y: 0)):
          selectedFoldIWAD = selectFolderDialog(trans.iwadsdirectoryHelper, getCurrentDir())
          if selectedFoldIWAD.len > 0:
            selectedFoldIWAD = fixFold(selectedFoldIWAD)
        igCalcTextSizeNonUDT(textSize.addr, trans.pwadsdirectory, nil, false, -1.0)
        igSetCursorPosX(style.windowPadding.x + availReg.x/2 - (textSize.x + style.itemSpacing.x + availReg.x/3) / 2)
        igAlignTextToFramePadding()
        igText(trans.pwadsdirectory)
        igSameLine()
        if igButton(extractFilename(pwadButtText) & "###select pwad dir button", ImVec2(x: availReg.x/3, y: 0)):
          selectedFoldPWAD = selectFolderDialog(trans.pwadsdirectoryHelper, getCurrentDir())
          if selectedFoldPWAD.len > 0:
            selectedFoldPWAD = fixFold(selectedFoldPWAD)


        igText("")

        if iAmFlatpak:
          igText("")
        else:
          igCalcTextSizeNonUDT(textSize.addr, trans.checkForUpdates & "    ", nil, false, -1.0) #idk what checkbox size is so spaces work just fine
          igSetCursorPosX(style.windowPadding.x + availReg.x/2 - (textSize.x + style.itemSpacing.x) / 2)
          igAlignTextToFramePadding()
          igText(trans.checkForUpdates)
          if igIsItemHovered():
            igSetTooltip(trans.checkForUpdatesFAQ)
          igSameLine()
          igCheckbox("##checkUpdates", checkForUpdates.addr)

        igCalcTextSizeNonUDT(textSize.addr, trans.closeonlaunch & "    ", nil, false, -1.0) #idk what checkbox size is so spaces work just fine
        igSetCursorPosX(style.windowPadding.x + availReg.x/2 - (textSize.x + style.itemSpacing.x) / 2)
        igAlignTextToFramePadding()
        igText(trans.closeonlaunch)
        if igIsItemHovered():
          igSetTooltip(trans.closeonlaunchFAQ)
        igSameLine()
        igCheckbox("##8003", closeOnLaunch.addr)

        igText("")
        igText("")
        igBeginDisabled(selectedFoldIWAD.len <= 0 or selectedFoldPWAD.len <= 0)
        igSetCursorPosX(style.windowPadding.x + availReg.x/2 - (availReg.x/2.5f)/2)
        if igButton(trans.save & "##8004", ImVec2(x: availReg.x/2.5f, y: itemHeight * 1.25f)):
          state.defaultIWADDirectory = selectedFoldIWAD
          state.defaultPWADDirectory = selectedFoldPWAD
          state.closeOnLaunch = closeOnLaunch
          state.checkForUpdates = checkForUpdates
          updateWADsLists()
          showSettingsModal = false
          if isFirstLaunch:
            isFirstLaunch = false
            igCloseCurrentPopup()
        igEndDisabled()

        igSetCursorPosY(availReg.y)
        igSeparator()
        igSetCursorPosX(style.windowPadding.x + availReg.x/2 - (availReg.x/3)/2)
        if igButton(trans.about, ImVec2(x: availReg.x/3, y: itemHeight * 0.95f)):
          showAbout = true
        igSeparator()
      else:
        var availRegChild: ImVec2
        igGetContentRegionAvailNonUDT(availReg.addr)
        igText("")
        igText("")
        igText("")
        igCalcTextSizeNonUDT(textSize.addr, trans.createdby & "much obliged", nil, false, -1.0)
        igSetCursorPosX(style.windowPadding.x + availReg.x/2 - textSize.x / 2)
        igText(trans.createdby)
        igSameLine()
        hyperlink("much obliged", "https://github.com/muchobliged")
        igText("")
        igText("")
        igCalcTextSizeNonUDT(textSize.addr, trans.extracredits, nil, false, -1.0)
        igSetCursorPosX(style.windowPadding.x + availReg.x/2 - textSize.x / 2)
        igText(trans.extracredits)
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
        var appVer: string = "Simple Doom Launcher - v" & $version
        when defined(linux):
          if iAmFlatpak:
            appVer.add(" Flatpak")
        igCalcTextSizeNonUDT(textSize.addr, appVer, nil, false, -1.0)
        igSetCursorPosX(style.windowPadding.x + availReg.x/2 - textSize.x / 2)
        hyperlink(appVer, "https://github.com/muchobliged/SimpleDoomLauncher")
        igSetCursorPosY(availReg.y - itemHeight)
        igSetCursorPosX(style.windowPadding.x + availReg.x/2 - (availReg.x/2)/2)
        if igButton(trans.back, ImVec2(x: availReg.x/2f, y: itemHeight * 1.25f)):
          showAbout = false
      igEndPopup()


#----------------------------------------------------


#----------------------------------------------------
#------------ Configure port popup begin ------------
#----------------------------------------------------

    igSetNextWindowSize(ImVec2(x: viewport.size.x / 2, y: viewport.size.y / 1.5f), ImGuiCond.Appearing)
    igSetNextWindowPos(windowCenter, ImGuiCond.Appearing, ImVec2(x: 0.5f, y: 0.5f))
    if igBeginPopupModal(trans.configureport & "###Configure Port Popup", showPortConfigModal.addr, ImGuiWindowFlags.NoResize):
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

      igSeparator()
      var isChanged: bool = false
      var availReg: ImVec2
      igGetContentRegionAvailNonUDT(availReg.addr)
      var textSize: ImVec2
      var foldText: string
      igText("")
      if not wantToDeletePort:

        foldText = trans.selectexecutable
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
            selectedPortExec = openFileDialog(trans.selectexecutable, getCurrentDir(), when defined(windows): ["*.exe"] else: ["*"], "Executable")
            isChanged = true
        else:
          when defined(linux):
            igSetCursorPosX(style.windowPadding.x + availReg.x/2 - buttSize/2)
            igSetNextItemWidth(buttSize)
            discard igCombo("##Flatpak99999", comboIndexFlatpak.addr, flatpakListCSTRING[0].addr, flatpakListCSTRING.len.int32, -1)
          else:
            discard #fallback


        igText("")
        igText("")
        igSeparator()
        igCalcTextSizeNonUDT(textSize.addr, trans.commandspreset, nil, false, -1.0)
        igSetCursorPosX(style.windowPadding.x + availReg.x/2 - (textSize.x + style.itemSpacing.x + availReg.x/3) / 2)
        igAlignTextToFramePadding()
        igText(trans.commandspreset)
        if igIsItemHovered():
          igBeginTooltip()
          for el in 0 .. iwadBehavOptionsExpl.high:
            igText(iwadBehavOptionsExpl[el])
          igEndTooltip()
        igSameLine()
        igSetNextItemWidth(availReg.x/3)
        discard igCombo("##99998", comboIndexIWADBehav.addr, iwadBehavOptionsCSTRING[0].addr, iwadBehavOptionsCSTRING.len.int32, -1)

        if not isThisFlatpak:
          igCalcTextSizeNonUDT(textSize.addr, trans.makeexecportable & "    ", nil, false, -1.0)
          igSetCursorPosX(style.windowPadding.x + availReg.x/2 - (textSize.x + style.itemSpacing.x) / 2)
          igAlignTextToFramePadding()
          igText(trans.makeexecportable)
          if igIsItemHovered():
            igSetTooltip(trans.makeexecportableFAQ)
          igSameLine()
          igCheckbox("##doPortable", doPortable.addr)


        igCalcTextSizeNonUDT(textSize.addr, trans.extraformats & "    ", nil, false, -1.0)
        igSetCursorPosX(style.windowPadding.x + availReg.x/2 - (textSize.x + style.itemSpacing.x) / 2)
        igAlignTextToFramePadding()
        igText(trans.extraformats)
        if igIsItemHovered():
          igSetTooltip(trans.extraformatsFAQ)
        igSameLine()
        igCheckbox("##extraformats", allowExtraFormats.addr)
        igSeparator()

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

        if isThisFlatpak:
          igText("")
        igBeginDisabled(not canSaveConfPort or (isThisFlatpak and not isFlatpak))
        igSetCursorPosX(style.windowPadding.x + availReg.x/2 - buttSize/2)
        if igButton(trans.save, ImVec2(x: buttSize, y: itemHeight * 1.25f)):
          state.ports[configuredPort].name = currentText
          if not isThisFlatpak:
            state.ports[configuredPort].path = selectedPortExec
            state.ports[configuredPort].doPortable = doPortable
          else:
            discard #fallback
            when defined(linux):
              state.ports[configuredPort].path = "%#%!" & $flatpakListCSTRING[comboIndexFlatpak]
              state.ports[configuredPort].doPortable = false
          state.ports[configuredPort].allowExtraFormats = allowExtraFormats
          state.ports[configuredPort].iwadBehav = comboIndexIWADBehav
          updateWADsLists()
          showPortConfigModal = false
          if not allowExtraFormats:
            removeUnsupportedPWADs(configuredPort)
        igEndDisabled()

        igSetCursorPosY(availReg.y)
        igSeparator()
        igSetCursorPosX(style.windowPadding.x + availReg.x/2 - (availReg.x / 2) / 2)
        if igButton(trans.removeport, ImVec2(x: availReg.x / 2, y: itemHeight * 0.95f)):
          wantToDeletePort = true
        igSeparator()
      else:
        igText("")
        igText("")
        igText("")
        igText("")
        var warningText: string = trans.removeportWarning[0]
        var warningText1: string = trans.removeportWarning[1]
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
        if igButton(trans.no & "##01234", ImVec2(x: availReg.x / 3, y: 0)):
          wantToDeletePort = false
        igSameLine()
        if igButton(trans.yes & "##12345", ImVec2(x: availReg.x / 3, y: 0)):
          wantToDeletePort = false
          showPortConfigModal = false
          deletePort(configuredPort)

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
      style.selectableTextAlign = ImVec2(x: 0.5f, y: 0.7f)
      var shouldDeleteConf = false
      var shouldAddTab = false
      var shouldRenameConf = false

      if shouldAddZDL:
        shouldAddZDL = false
        if igIsMouseHoveringRect(ImVec2(x: state.leftWindowWidth, y: 0), ImVec2(x: viewport.size.x, y: viewport.size.y), false):
          var zdlPath = dragPath
          if zdlPath.len > 0:
            loadZDL(zdlPath)
          if readyZDL:
            shouldAddTab = true

      if shouldImportTab:
        if not igIsMouseHoveringRect(ImVec2(x: state.leftWindowWidth, y: 0), ImVec2(x: viewport.size.x, y: viewport.size.y), false):
          shouldImportTab = false


      if igSelectable("  +  ", false, ImGuiSelectableFlags.None, ImVec2(x: availReg.x/20, y: itemHeight)):
        shouldAddTab = true

      if igBeginPopupContextItem("  +  " & "##tryToAddStuff", ImGuiPopupFlags.MouseButtonRight):
        var availRegTabsRenamePopup: ImVec2
        igGetContentRegionAvailNonUDT(availRegTabsRenamePopup.addr)

        if copyConfig:
          if igButton(trans.paste, ImVec2(x: availRegTabsRenamePopup.x, y: 0)):
            shouldPasteConfig = true
            shouldAddTab = true
            igCloseCurrentPopup()

        if igButton(trans.importCFG, ImVec2(x: availRegTabsRenamePopup.x, y: 0)):
          var path = openFileDialog(trans.importCFG, getCurrentDir(), @["*.sdl_cfg"], "Port Config")
          var cfg: PortConfig
          if path.len > 0:
            cfg = importConfig(path)
            bufferConfigImport = cfg
            shouldImportTab = true
          igCloseCurrentPopup()

        if igButton(trans.addzdlconfig, ImVec2(x: availRegTabsRenamePopup.x, y: 0)):
          var zdlPath = openFileDialog(trans.selectzdlconfig, getCurrentDir(), @["*.zdl"], "ZDL Config")
          if zdlPath.len > 0:
            loadZDL(zdlPath)
          if readyZDL:
            shouldAddTab = true
          igCloseCurrentPopup()

        igEndPopup()

      var port = addr(state.ports[state.selectedPort])
      if port.configs.len > 0:
        var confs = addr(state.ports[state.selectedPort].configs)
        for i in 0 .. confs[].high:                         #populating tabs
          var tab = confs[i]
          igPushID($tab.name)
          igSameLine()
          if igSelectable(tab.name, port.selectedConfig == i, ImGuiSelectableFlags.None, ImVec2(x: availReg.x/5, y: itemHeight)):
            port.selectedConfig = i
            updateWADsLists()
          if port.selectedConfig == i:
            if igBeginPopupContextItem($tab.name & "##tabDeletePopUp", ImGuiPopupFlags.MouseButtonRight):
              var availRegTabsRenamePopup: ImVec2
              igGetContentRegionAvailNonUDT(availRegTabsRenamePopup.addr)
              if igButton(trans.exportCFG, ImVec2(x: availRegTabsRenamePopup.x, y: 0)):
                var expPath = saveFileDialog(trans.exportCFG, getCurrentDir() / tab.name, ["*.sdl_cfg"], "Port config")
                if expPath.len > 0:
                  exportConfig(tab, expPath)
                igCloseCurrentPopup()

              if igButton(trans.copy, ImVec2(x: availRegTabsRenamePopup.x, y: 0)):
                bufferConfig = tab
                copyConfig = true
                igCloseCurrentPopup()


              if igButton(trans.rename, ImVec2(x: availRegTabsRenamePopup.x, y: 0)):
                shouldRenameConf = true
                igCloseCurrentPopup()


              if igButton(trans.delete, ImVec2(x: availRegTabsRenamePopup.x, y: 0)):
                shouldDeleteConf = true
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


      if shouldImportTab and bufferConfigImport.name.len > 0:
        var numb: int = 0
        var confName: string = bufferConfigImport.name
        var nameOk: bool = true

        for i in 0 .. state.ports[state.selectedPort].configs.high:
          if confName == $state.ports[state.selectedPort].configs[i].name:
            nameOk = false
            break

        while not nameOk:
          nameOk = true
          numb += 1
          confName = $numb
          for i in 0 .. state.ports[state.selectedPort].configs.high:
            if $confName == $state.ports[state.selectedPort].configs[i].name:
              nameOk = false
              break

        bufferConfigImport.name = $confName
        state.ports[state.selectedPort].configs.insert(bufferConfigImport)
        shouldImportTab = false
        if not state.ports[state.selectedPort].allowExtraFormats:
          removeUnsupportedPWADs(state.selectedPort, 0)
        port.selectedConfig = 0
        bufferConfigImport = PortConfig()

      if state.ports[state.selectedPort].configs.len <= 0:  # so there's always at least one config created
        shouldAddTab = true

      if shouldAddTab:
        var numb: int = 0
        var confName: string
        var nameOk: bool = false

        if shouldPasteConfig and not readyZDL:
          nameOk = true
          confName = bufferConfig.name
          for i in 0 .. state.ports[state.selectedPort].configs.high:
            if confName == $state.ports[state.selectedPort].configs[i].name:
              nameOk = false
              break

        while not nameOk:
          nameOk = true
          numb += 1
          confName = $numb
          for i in 0 .. state.ports[state.selectedPort].configs.high:
            if $confName == $state.ports[state.selectedPort].configs[i].name:
              nameOk = false
              break

        if not readyZDL and not shouldPasteConfig:
          state.ports[state.selectedPort].configs.insert(PortConfig(name: $confName), 0)
        elif readyZDL and not shouldPasteConfig:
          state.ports[state.selectedPort].configs.insert(PortConfig(name: $confName, pwads: if newZDLPWADS.len > 0: newZDLPWADS else: @[], commands: if newZDLExtra.len > 0: newZDLExtra else: ""), 0)
          readyZDL = false
          if not state.ports[state.selectedPort].allowExtraFormats:
            removeUnsupportedPWADs(state.selectedPort, 0)
        elif shouldPasteConfig and not readyZDL:
          bufferConfig.name = $confName
          state.ports[state.selectedPort].configs.insert(bufferConfig)
          shouldPasteConfig = false
          if not state.ports[state.selectedPort].allowExtraFormats:
            removeUnsupportedPWADs(state.selectedPort, 0)
        port.selectedConfig = 0

      style.selectableTextAlign = ImVec2(x: 0, y: 0.5f)

      igSeparator()
      igEndChild()

      if shouldRenameConf:
        showConfRenameModal = true
        textBuf[0] = '\0'
        currentText = ""
        igOpenPopup("###Configuration rename")

      if shouldDeleteConf:
        showConfDeleteModal = true
        igOpenPopup("###Configuration delete")

#----------------------------------------------------
#------------ Rename tab(conf) popup begin ----------
#----------------------------------------------------


      igSetNextWindowSize(ImVec2(x: viewport.size.x / 3, y: viewport.size.y / 3), ImGuiCond.Appearing)
      igSetNextWindowPos(windowCenter, ImGuiCond.Appearing, ImVec2(x: 0.5f, y: 0.5f))
      if igBeginPopupModal(trans.configurationrename & "###Configuration rename", showConfRenameModal.addr, ImGuiWindowFlags.NoResize):
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
        if igButton(trans.save & "##434343", ImVec2(x: buttSize, y: itemHeight * 1.25f)):
          selConf.name = currentText
          showConfRenameModal = false
        igEndDisabled()
        igEndPopup()


#----------------------------------------------------
#------------ Delete tab(conf) popup begin ----------
#----------------------------------------------------


      igSetNextWindowSize(ImVec2(x: viewport.size.x / 3, y: viewport.size.y / 3), ImGuiCond.Appearing)
      igSetNextWindowPos(windowCenter, ImGuiCond.Appearing, ImVec2(x: 0.5f, y: 0.5f))
      if igBeginPopupModal(trans.configurationdelete & "###Configuration delete", showConfDeleteModal.addr, ImGuiWindowFlags.NoResize):
        if igIsKeyPressed(256, false):          #for some reason nimgl bindings don't work, so 256 = Escape
          showConfDeleteModal = false
        var textSize: ImVec2
        var availReg: ImVec2
        igGetContentRegionAvailNonUDT(availReg.addr)
        igSeparator()
        igText("")
        var warningText: string = trans.removeconfigWarning[0]
        var warningText1: string = trans.removeconfigWarning[1]
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
        if igButton(trans.no & "##01234", ImVec2(x: availReg.x / 3, y: 0)):
          showConfDeleteModal = false
        igSameLine()
        if igButton(trans.yes & "##12345", ImVec2(x: availReg.x / 3, y: 0)):
          showConfDeleteModal = false
          deleteConf(state.selectedPort, state.ports[state.selectedPort].selectedConfig)
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
          if igSelectable(trans.iwadsnotfound, false):
            shouldOpenSettings = true

          if igIsItemHovered():
            igSetTooltip(trans.selectproperiwadsdir)

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
        if igSelectable(trans.addcustompwad):
          customWAD = openFileDialog(trans.addcustompwad, if state.defaultPWADDirectory != "": state.defaultPWADDirectory else: getCurrentDir(), if state.ports[state.selectedPort].allowExtraFormats: allExtensionsAst else: @["*.wad"], "WADs")
          if conf.pwads.contains(customWAD):
            customWAD = ""
        igSeparator()

        if shouldAddDragWAD:
          shouldAddDragWAD = false
          if igIsMouseHoveringRect(ImVec2(x: state.leftWindowWidth, y: 0), ImVec2(x: viewport.size.x, y: viewport.size.y), false):
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
          if igSelectable(trans.pwadsnotfound, false):
            shouldOpenSettings = true

          if igIsItemHovered():
            igSetTooltip(trans.selectproperpwadsdir)

          igSeparator()

        igEndListBox()
        igText("")
        igCalcTextSizeNonUDT(textSize.addr, trans.extracommands, nil, false, -1.0)
        igGetContentRegionAvailNonUDT(availRegTabs.addr)
        igSetCursorPosX(availRegTabs.x/2 - textSize.x / 2)
        igText(trans.extracommands)
        buttSize = availRegTabs.x/2
        igSetCursorPosX(availRegTabs.x/2 - buttSize / 2)
        igSetNextItemWidth(buttSize)
        if igInputTextWithHint("##inputCommands", "-skill 4", confCommandsTextBuf[0].addr, 256):
          conf.commands = $cstring(confCommandsTextBuf[0].addr)

        igSameLine()
        #igAlignTextToFramePadding()
        igText("(?)")
        if igIsItemHovered():
          igBeginTooltip()
          for it in trans.extracommandsFAQ:
            igText(it)
          igEndTooltip()

        igText("")
        igText("")
        igBeginDisabled(not canPlay)
        buttSize = availRegTabs.x/2
        igSetCursorPosX(availRegTabs.x/2 - buttSize/2)
        if igButton(if canPlay: trans.play else: trans.iwadsnotfound, ImVec2(x: buttSize, y: itemHeight * 2)):
          if conf.iwad.len <= 0 and iwadList.len > 0:
            conf.iwad = iwadList[0]
          elif not iwadList.contains(conf.iwad):
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
