import std/[jsonutils, json, os, osproc, strutils, sequtils, envvars, strtabs, streams, algorithm]
from std/unicode import runeLen, runeSubstr


type
  SourcePort* = object
    name*: string
    path*: string
    iwadBehav*: int32 = 0
    allowExtraFormats*: bool = true
    selectedConfig*: int = 0
    doPortable*: bool = false
    configs*: seq[PortConfig]

  PortConfig* = object
    name*: string
    iwad*: string
    pwads*: seq[string]
    commands*: string

  ProgramState* = object
    ports*: seq[SourcePort]
    selectedPort*: int = 0
    defaultIWADDirectory*: string
    defaultPWADDirectory*: string
    closeOnLaunch*: bool = false
    leftWindowWidth*: float32 = 125
    styleIndex*: int32 = 0
    lang*: int32 = 0
    checkForUpdates*: bool = true
    relativePaths*: bool = false
    extraButtons*: bool = false


let appName: string = "MO_SimpleDoomLauncher"

var version*: float = 1.3
var latestVersion*: float = 0
var showUpdateModal*: bool = false

var configPath: string
var isFirstLaunch*: bool = true
var state*: ProgramState
var bufferConfig*: PortConfig
var bufferConfigImport*: PortConfig
var copyConfig*: bool = false
#var systemFont*: string = ""
var isFlatpak*: bool = false
var iAmFlatpak*: bool = false

var readyZDL*: bool = false
var newZDLPWADS*: seq[string] = @[]
var newZDLExtra*: string = ""

var allExtensions* = @[".wad",".pk3", ".pk4", ".pk7", ".pke"]
var allExtensionsAst* = @["*.wad","*.pk3", "*.pk4", "*.pk7", "*.pke"]

var iwadBehavOptions = @["Default", "Doomsday"]
var iwadBehavOptionsExpl* = @["Default: -iwad <iwad.wad> -file <pwad.wad>", "Doomsday: -iwad <directory> -file <pwad.wad>"]

var iwadBehavOptionsCSTRING*: seq[cstring] = iwadBehavOptions.mapIt(it.cstring)

var langs = @["English", "Русский"]

var langsCSTRING*: seq[cstring] = langs.mapIt(it.cstring)

const loadOptions = Joptions(allowMissingKeys: true, allowExtraKeys: true)

#get path of the system font, so to not ship .ttf with the program itself. Yet, currently maybe it's not needed in the project
#[proc getDefaultSystemFontPath(): string =
  when defined(windows):
    const fontsDir = r"C:\Windows\Fonts"
    const possibleFiles = ["segoeui.ttf", "tahoma.ttf", "arial.ttf"]
    for f in possibleFiles:
      let path = fontsDir / f
      if fileExists(path):
        return path
    return ""

  elif defined(linux):
    let (output, exitCode) = execCmdEx("fc-match --format='%{file}'")
    if exitCode != 0:
      return ""
    let path = output.strip()
    if path != "" and fileExists(path):
      return path
    return ""

  else:
    return ""]#

when defined(linux):
  iAmFlatpak = getEnv("container") == "flatpak" or existsEnv("FLATPAK_ID")
  isFlatpak = findExe("flatpak").len > 0 or iAmFlatpak
  var flatpakList: seq[string]


  proc getFlatpakSpawnPath(): string =
    let found = findExe("flatpak-spawn")
    if found != "":
      return found
    # Fallback: standard location in Freedesktop runtime
    if fileExists("/usr/bin/flatpak-spawn"):
      return "/usr/bin/flatpak-spawn"
    if fileExists("/app/bin/flatpak-spawn"):
      return "/app/bin/flatpak-spawn"
    raise newException(OSError, "flatpak-spawn not found")

  proc getFlatpakList(): seq[string] =
    var flatpakSpawnPath: string
    if iAmFlatpak:
      flatpakSpawnPath = getFlatpakSpawnPath() & " --host "
    let (output, exitCode) = execCmdEx(flatpakSpawnPath & "flatpak list --app --columns=application")
    if exitCode == 0:
      return output.splitLines().filterIt(it != "")
    return @[]


  if isFlatpak:
    flatpakList = getFlatpakList()
  var flatpakListCSTRING*: seq[cstring] = flatpakList.mapIt(it.cstring)
  if flatpakList.len <= 0:
    flatpakListCSTRING = @["Flatpak not found!"]
    isFlatpak = false

else:
  isFlatpak = false

proc canDoUpdates(): int = # 0 - no, 1 - curl, 2 - powershell
  when defined(linux):
    if iAmFlatpak or findExe("curl") == "":
      return 0
    else:
      return 1
  elif defined(windows):
    if findExe("curl") != "":
      return 1
    elif findExe("powershell") != "":
      return 2
    else:
      return 0

proc getLatestAppVersion*() {.gcsafe.} =
  latestVersion = 0
  var cmd: string = ""

  var powershellCmd = "powershell -NoProfile -Command \"(Invoke-WebRequest -Uri 'https://api.github.com/repos/muchobliged/SimpleDoomLauncher/releases/latest' -UseBasicParsing).Content\""
  var curlCmd = "curl -sL -H \"User-Agent: Nim\" -H \"Accept: application/vnd.github+json\" https://api.github.com/repos/muchobliged/SimpleDoomLauncher/releases/latest"

  case canDoUpdates():
    of 1:
      cmd = curlCmd
    of 2:
      cmd = powershellCmd
    else:
      latestVersion = 0
      return
  try:
    let (jsonResponse, exitCode) = execCmdEx(cmd, options = {poUsePath, poDaemon})

    if exitCode == 0 and jsonResponse.strip() != "":
      let data = parseJson(jsonResponse)

      if data.hasKey("tag_name"):
        latestVersion = parseFloat(data["tag_name"].getStr().strip()[1 .. ^1])
      else:
        latestVersion = 0
        return

    else:
      latestVersion = 0
      return
  except:
    latestVersion = 0
    return

  if latestVersion > version:
    showUpdateModal = true


proc openGitHub*() =
  var url = "https://github.com/muchobliged/SimpleDoomLauncher/releases/latest"
  when defined(linux):
      discard execProcess("xdg-open " & quoteShell(url))
  elif defined(windows):
    discard startProcess("explorer.exe", args = [quoteShell(url)], options = {poDaemon})


proc loadZDL*(p: string) =
  readyZDL = false
  if fileExists(p):
    newZDLPWADS = @[]
    newZDLExtra = ""
    let zdlString = readFile(p)
    for line in zdlString.splitLines:
      if line.startsWith("file"):
        if line.split('=', 1)[1].len > 0:
          newZDLPWADS.add(line.split('=', 1)[1])
      elif line.startsWith("extra="):
        if line.split('=', 1)[1].len > 0:
          newZDLExtra = line.split('=', 1)[1]
    if newZDLPWADS.len > 1:
      newZDLPWADS = newZDLPWADS.deduplicate()
    if newZDLExtra.len > 0 or newZDLPWADS.len > 0:
      readyZDL = true


proc ifExtensionCorrect*(path: string): bool =
  if allExtensions.anyIt(path.toLower().endsWith(it)):
    return true
  else:
    return false

proc doPortable(portIndx: int, portExec: string): StringTableRef =
  var env = newStringTable(modeCaseSensitive)
  var homevar = $portExec & ".home"

  for key, value in envPairs():
    env[key] = value
  if state.ports[portIndx].doPortable:
    if not dirExists(homevar):
      createDir(homevar)
    when defined(linux):
      env["HOME"] = homevar
    elif defined(windows):
      env["HOME"] = homevar
      env["USERPROFILE"] = homevar
  result = env

proc setArgs(portIndx: int, confIndx: int): seq[seq[string]] =
    var args: seq[string]
    var preCommands: seq[string] = @[]
    var postCommands: seq[string]
    var iwad = state.ports[portIndx].configs[confIndx].iwad
    var pwads = state.ports[portIndx].configs[confIndx].pwads
    var commands = state.ports[portIndx].configs[confIndx].commands.split(';', 1)
    var portIwadBehav = state.ports[portIndx].iwadBehav

    if commands.len > 1:
      preCommands = commands[0].splitWhitespace()
      postCommands = commands[1].splitWhitespace()
    else:
      postCommands = commands[0].splitWhitespace()

    args.add("-iwad")

    if portIwadBehav == 0:  #-iwad <iwad.wad> -file <pwad.wad>
      args.add($iwad)
    else:                   #-iwad <directory> -file <pwad.wad>
      args.add(splitFile($iwad).dir)

    if pwads.len > 0:
      args.add("-file")

    for i in 0 .. pwads.high:
      args.add(pwads[i])

    args.add(postCommands)
    result = @[preCommands, args]


proc runPort*(portIndx: int, confIndx: int) =
    var doFlatpak: bool = false
    var portExec = state.ports[portIndx].path
    var runArgs = setArgs(portIndx, confIndx)

    when defined(windows):
      if fileExists(portExec):
        try:
          let process = startProcess(
              command = portExec,
              workingDir = splitFile(portExec).dir,
              args = runArgs[0] & runArgs[1],
              env = doPortable(portIndx, portExec),
              options = {poParentStreams}
          )
        except:
          discard

    when defined(linux):
      var launchComm: string = ""
      var launchFromFlatpak: seq[string] = @[]

      if portExec.startsWith("%#%!"):
        doFlatpak = true
        portExec = portExec.split('!', 1)[1]

      launchComm = portExec


      if not doFlatpak:
        if iAmFlatpak:
          launchComm = getFlatpakSpawnPath()
          launchFromFlatpak = @["--host", portExec]

        if fileExists(portExec):
          try:
            let process = startProcess(
                command = launchComm,
                workingDir = splitFile(portExec).dir,
                args = launchFromFlatpak & runArgs[0] & runArgs[1],
                env = doPortable(portIndx, portExec),
                options = {poParentStreams}
            )
          except:
            discard
      else:
        var flatpakPath: string
        var flatpakArgs: seq[string] = @[]
        var iwad = state.ports[portIndx].configs[confIndx].iwad
        var pwads = state.ports[portIndx].configs[confIndx].pwads
        var wadsDirs: seq[string] = @[]            # directories with wads, to give flatpak port permission to access

        wadsDirs.add(splitFile($iwad).dir)
        for i in 0 .. pwads.high:
          wadsDirs.add(splitFile(pwads[i]).dir)
        wadsDirs = wadsDirs.deduplicate()


        if iAmFlatpak:
          flatpakPath = getFlatpakSpawnPath()
          flatpakArgs.add("--host")
          flatpakArgs.add("flatpak")
        else:
          flatpakPath = findExe("flatpak")

        flatpakArgs.add("run")
        flatpakArgs.add(runArgs[0])
        for i in 0 .. wadsDirs.high:
          flatpakArgs.add("--filesystem=" & wadsDirs[i])      #give flatpak port permission to access directories with wads
        flatpakArgs.add($portExec)
        flatpakArgs.add(runArgs[1])
        try:
          let process = startProcess(
              command = flatpakPath,
              args = flatpakArgs,
              options = {poParentStreams}
          )
        except:
          discard

proc changeDirNameWithBrackets*(str: string): string =
  let totalWidth = 18
  let innerWidth = totalWidth - 2

  var text = str
  if text.runeLen > innerWidth:
    text = text.runeSubstr(0, innerWidth)

  let totalPadding = innerWidth - text.runeLen
  let rightPadding = totalPadding div 2
  let leftPadding = totalPadding - rightPadding

  let leftSpaces = " ".repeat(leftPadding)
  let rightSpaces = " ".repeat(rightPadding)

  return "[" & leftSpaces & text & rightSpaces & "]"



proc getSmallerString*(str: string, leng: int = 100): string =
  var newStr = str
  let rlen = newStr.runeLen

  if rlen <= leng:
    return str

  return "~" & newStr.runeSubstr(rlen - leng, rlen)


proc readTXT*(filename: string): seq[string] =    # need to check if the file a real TXT or a fake one to avoid crashes. Maybe overkill...
  var f: File
  if not open(f, filename):
    return @[]
  defer: close(f)

  const SampleSize = 4096   # read first 4 KB

  var buf: array[SampleSize, char]
  let n = f.readBuffer(addr buf[0], SampleSize)
  if n == 0:
    return @[]

  var nulls = 0
  var nonPrintable = 0
  for i in 0 ..< n:
    let c = buf[i]
    if c == '\0':
      nulls.inc
    else:
      # Control characters except tab, newline, carriage return
      if c notin {'\t', '\n', '\r'} and ord(c) < 32:
        nonPrintable.inc

  if nulls > 0 or nonPrintable * 10 > n:
    return @[]

  return readFile(filename).splitLines()



proc findTXT*(path: string): string =
  var pwadPath = path
  when defined(windows):
    if fileExists(changeFileExt(pwadPath, "txt")):
      return changeFileExt(pwadPath, "txt")
  else:
    var txtList: seq[string] = @[]
    for kind, pathItem in walkDir(splitFile(pwadPath).dir):
      if kind == pcFile:
        if pathItem.toLower().endsWith(".txt"):
          if changeFileExt(pwadPath, "txt").toLower() == pathItem.toLower():
            return pathItem
  return ""


proc walkSelectedDir*(path: string, ext: seq[string], isIWAD: bool = false): seq[string] =
  var files: seq[string] = @[]
  var folders: seq[string] = @[]
  result = @[]
  for kind, filePath in walkDir(path):
    if kind == pcFile:
      for p in 0 .. ext.high:
        if filePath.toLower().endsWith(ext[p]):
          files.add(filePath)
          break
    elif kind == pcDir and not isIWAD:
      folders.add(filePath & " - i am folder!@#@!")
  result.add(folders.sorted(cmpIgnoreCase))
  result.add(files.sorted(cmpIgnoreCase))

proc fixFold*(path: string): string =
  var p = path
  if p.endsWith('/') and p.len > 1:
    p = p[0 .. ^2]   # drop last char
  result = p


proc removeUnsupportedPWADs*(portIndx: int) =
  for i in 0 .. state.ports[portIndx].configs.high:
    for j in 1 .. allExtensions.high:
      state.ports[portIndx].configs[i].pwads = state.ports[portIndx].configs[i].pwads.filterIt(not it.toLower().endsWith(allExtensions[j]))

proc removeUnsupportedPWADs*(portIndx: int, confIndx: int) =
  for j in 1 .. allExtensions.high:
    state.ports[portIndx].configs[confIndx].pwads = state.ports[portIndx].configs[confIndx].pwads.filterIt(not it.toLower().endsWith(allExtensions[j]))


proc deleteConf*(portIndx: int, confIndx: int) =
  if confIndx > 0 and confIndx == state.ports[portIndx].selectedConfig:
    state.ports[portIndx].selectedConfig = confIndx - 1
  state.ports[portIndx].configs.delete(confIndx)

proc deletePort*(indx: int) =
  if indx == 0:
    state.selectedPort = 0
  else:
    state.selectedPort = indx - 1
  state.ports.delete(indx)


proc getSystemIntegration*(): bool =
  var path = ""
  when defined(linux):
    path = getEnv("HOME") & "/.local/share/applications/io.github.muchobliged.SimpleDoomLauncher.desktop"
  elif defined(windows):
    path = getEnv("APPDATA") & "\\Microsoft\\Windows\\Start Menu\\Programs\\Simple Doom Launcher.lnk"

  if fileExists(path):
    return true
  else:
    return false

proc integrateIntoSystemUndo*() {.gcsafe.} =
  var path = ""
  when defined(linux):
    path = getEnv("HOME") & "/.local/share/applications/io.github.muchobliged.SimpleDoomLauncher.desktop"
  elif defined(windows):
    path = getEnv("APPDATA") & "\\Microsoft\\Windows\\Start Menu\\Programs\\Simple Doom Launcher.lnk"

  if fileExists(path):
    try:
      removeFile(path)
    except:
      discard

proc integrateIntoSystem*() {.gcsafe.} =
  when defined(linux):
    let appImageEnv = getEnv("APPIMAGE")
    if appImageEnv != "":
      let appDir = getEnv("APPDIR")
      var iconPath = "/usr/share/icons/hicolor/256x256/apps/io.github.muchobliged.SimpleDoomLauncher.png"
      try:
        copyFile(appDir & iconPath, splitFile(appImageEnv).dir & "/io.github.muchobliged.SimpleDoomLauncher.png")
        iconPath = splitFile(appImageEnv).dir & "/io.github.muchobliged.SimpleDoomLauncher.png"
        let desktopInfo = "[Desktop Entry]\nType=Application\nName=Simple Doom Launcher\nComment=Just a simple Doom launcher\nExec=" & appImageEnv & "\nIcon=" & iconPath & "\nCategories=Game;"

        let desktopPath = getEnv("HOME") & "/.local/share/applications"
        if not dirExists(desktopPath):
          createDir(desktopPath)
        writeFile(desktopPath & "/io.github.muchobliged.SimpleDoomLauncher.desktop", desktopInfo)
      except:
        discard
  elif defined(windows):
    if findExe("powershell") != "":
      let linkPath = getEnv("APPDATA") & "\\Microsoft\\Windows\\Start Menu\\Programs\\Simple Doom Launcher.lnk"

      var powershellCmd = "powershell -NoProfile -Command \"$WScriptShell = New-Object -ComObject WScript.Shell; $Shortcut = $WScriptShell.CreateShortcut('" & linkPath & "'); $Shortcut.TargetPath = '" & getAppFilename() & "'; $Shortcut.Save()\""
      try:
        discard execCmdEx(powershellCmd, options = {poUsePath, poDaemon})
      except:
        discard


proc isExecutable*(filename: string): bool =
  if fileExists(filename):
    when defined(windows):
      if splitFile(filename).ext == ".exe": return true
    else:
      var f = openFileStream(filename, fmRead)
      defer: f.close()
      let magic = f.readStr(4)   # reads up to 4 bytes as a string
      if magic.len < 4: return false  # file too small
      if magic.startsWith("#!"): return true
      if magic == "\x7FELF": return true
      return false
  else:
    return false

proc getConfigPath(): string =
  when defined(windows):
    return splitFile(getAppFilename()).dir
  when defined(linux):
    if iAmFlatpak:
      return getConfigDir()
    else:
      let appImageEnv = getEnv("APPIMAGE")
      if appImageEnv != "":
        return splitFile(appImageEnv).dir
      else:
        return splitFile(getAppFilename()).dir

proc exportConfig*(cfg: PortConfig, path: string) =
  let jsonNode = cfg.toJson()
  writeFile(path, jsonNode.pretty())

proc importConfig*(path: string): PortConfig =
  if fileExists(path):
    try:
      let jsonString = readFile(path)
      let jsonNode = parseJson(jsonString)
      result = jsonNode.jsonTo(PortConfig, loadOptions)
    except:
      echo "Config file is broken!"


proc makePathRelative(com: bool, str: string, appPath: string): string =
  var searchStr = ""
  var addStr = ""

  if com:
    searchStr = appPath
    addStr = "!RELATIVE! - "
  else:
    searchStr = "!RELATIVE! - "
    addStr = appPath

  if str.startsWith(searchStr):
    return addStr & str.split(searchStr, 1)[1]
  else:
    return str



proc makeStateRelative(com: bool) =
  let appPath = splitFile(getAppFilename()).dir
  state.defaultIWADDirectory = makePathRelative(com, state.defaultIWADDirectory, appPath)
  state.defaultPWADDirectory = makePathRelative(com, state.defaultPWADDirectory, appPath)

  for i in 0 .. state.ports.high:
    state.ports[i].path = makePathRelative(com, state.ports[i].path, appPath)
    for j in 0 .. state.ports[i].configs.high:
      state.ports[i].configs[j].iwad = makePathRelative(com, state.ports[i].configs[j].iwad, appPath)
      for k in 0 .. state.ports[i].configs[j].pwads.high:
        state.ports[i].configs[j].pwads[k] = makePathRelative(com, state.ports[i].configs[j].pwads[k], appPath)


proc saveConfig*() =
  makeStateRelative(state.relativePaths)
  let jsonNode = state.toJson()
  writeFile(configPath & "/config.sdl", jsonNode.pretty())

proc loadConfig(): ProgramState =
  if not fileExists(configPath & "/config.sdl"):
    isFirstLaunch = true
    return ProgramState()
  else:
    isFirstLaunch = false

  try:
    let jsonString = readFile(configPath & "/config.sdl")
    let jsonNode = parseJson(jsonString)
    result = jsonNode.jsonTo(ProgramState, loadOptions)
  except:
    echo "Config file is broken!"
    isFirstLaunch = true
    return ProgramState()

configPath = getConfigPath()
state = loadConfig()
makeStateRelative(false)  # make paths unrelative

if state.defaultIWADDirectory.len <= 0 or state.defaultPWADDirectory.len <= 0:
  isFirstLaunch = true
#systemFont = getDefaultSystemFontPath()

