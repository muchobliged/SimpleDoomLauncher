import std/[jsonutils, json, os, osproc, strutils, sequtils, envvars, strtabs]

type
  SourcePort* = object
    name*: string
    path*: string
    iwadBehav*: int32 = 0
    allowExtraFormats*: bool = true
    selectedConfig*: int = 0
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
    doPortable*: bool = true
    closeOnLaunch*: bool = false
    leftWindowWidth*: float32 = 125
    styleIndex*: int32 = 0
    lang*: int32 = 0


let appName: string = "MO_SimpleDoomLauncher"

var version*: string = "Ver. 1.1"

var configPath: string
var isFirstLaunch*: bool = true
var state*: ProgramState
var bufferConfig*: PortConfig
var copyConfig*: bool = false
#var systemFont*: string = ""
#var iAmFlatpak*: bool = false

var readyZDL*: bool = false
var newZDLPWADS*: seq[string] = @[]
var newZDLExtra*: string = ""

var allExtensions* = @[".wad",".pk3", ".pk7"]
var allExtensionsAst* = @["*.wad","*.pk3", "*.pk7"]

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
  var isFlatpak*: bool = findExe("flatpak").len > 0
  var flatpakList: seq[string]

  proc getFlatpakList(): seq[string] =
    let (output, exitCode) = execCmdEx("flatpak list --app --columns=application")
    if exitCode == 0:
      return output.splitLines().filterIt(it != "")
    return @[]


  if isFlatpak:
    flatpakList = getFlatpakList()
  var flatpakListCSTRING*: seq[cstring] = flatpakList.mapIt(it.cstring)
  if flatpakList.len <= 0:
    flatpakListCSTRING = @["Flatpak not found!"]
    isFlatpak = false

  #proc amIFlatpak(): bool =
    #getEnv("container") == "flatpak" or
    #existsEnv("FLATPAK_ID")

else:
  var isFlatpak*: bool = false


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

proc doPortable(portExec: string): StringTableRef =
  var env = newStringTable(modeCaseSensitive)
  var homevar = $portExec & ".home"
  for key, value in envPairs():
    env[key] = value
  if state.doPortable:
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
    #var commands = strutils.splitWhitespace(state.ports[portIndx].configs[confIndx].commands)
    var commands = state.ports[portIndx].configs[confIndx].commands.split(';', 1)
    #echo $commands & "commands"
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
    #echo @[preCommands, args]
    result = @[preCommands, args]

proc runPort*(portIndx: int, confIndx: int) =
    var doFlatpak: bool = false
    var portExec = state.ports[portIndx].path
    when defined(linux):
      if portExec.startsWith("%#%!"):
        doFlatpak = true
        portExec = portExec.split('!', 1)[1]

    var runArgs = setArgs(portIndx, confIndx)
    if not doFlatpak:
      if fileExists(portExec):
        let process = startProcess(
            command = portExec,
            workingDir = splitFile(portExec).dir,
            args = runArgs[0] & runArgs[1],
            env = doPortable(portExec),
            options = {poParentStreams}
        )
    else:
      when defined(linux):
        var iwad = state.ports[portIndx].configs[confIndx].iwad
        var pwads = state.ports[portIndx].configs[confIndx].pwads
        var wadsDirs: seq[string] = @[]            # directories with wads, to give flatpak port permission to access
        wadsDirs.add(splitFile($iwad).dir)
        for i in 0 .. pwads.high:
          wadsDirs.add(splitFile(pwads[i]).dir)
        wadsDirs = wadsDirs.deduplicate()

        var flatpakArgs: seq[string] = @["run"]    #"--socket=x11", "--nosocket=wayland"
        flatpakArgs.add(runArgs[0])
        for i in 0 .. wadsDirs.high:
          flatpakArgs.add("--filesystem=" & wadsDirs[i])      #give flatpak port permission to access directories with wads
        flatpakArgs.add($portExec)
        flatpakArgs.add(runArgs[1])
        let flatpakPath = findExe("flatpak")
        #echo $flatpakArgs
        let process = startProcess(
            command = flatpakPath,
            args = flatpakArgs,
            options = {poParentStreams}
        )
      else:
        discard


proc walkSelectedDir*(path: string, ext: seq[string]): seq[string] =
  result = @[]
  for kind, filePath in walkDir(path):
    if kind == pcFile:
      for p in 0 .. ext.high:
        if filePath.toLower().endsWith(ext[p]):
          result.add(filePath)
          break


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
  if indx > 0:
    state.selectedPort = indx - 1
  state.ports.delete(indx)

proc isExecutable*(filename: string): bool =
  if fileExists(filename):
    when defined(windows):
      if splitFile(filename).ext == ".exe":
        return true
    else:             # maybe need to prohibit .exe?
      let filePermissions = getFilePermissions filename
      fpUserExec in filePermissions and
        fpGroupExec in filePermissions and
          fpOthersExec in filePermissions
  else:
    return false

proc saveConfig*() =
  let jsonNode = state.toJson()
  writeFile(configPath & "/config.json", jsonNode.pretty())

proc loadConfig*(): ProgramState =
  if not fileExists(configPath & "/config.json"):
    if not dirExists(configPath):
      createDir(configPath)
    isFirstLaunch = true
    return ProgramState()
  else:
    isFirstLaunch = false

  let jsonString = readFile(configPath & "/config.json")
  let jsonNode = parseJson(jsonString)
  result = jsonNode.jsonTo(ProgramState, loadOptions)


configPath = getConfigDir() & appName
#echo configPath
state = loadConfig()

if state.defaultIWADDirectory.len <= 0 or state.defaultPWADDirectory.len <= 0:
  isFirstLaunch = true

#systemFont = getDefaultSystemFontPath()

