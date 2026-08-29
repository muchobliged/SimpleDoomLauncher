import nimgl/imgui
import std/sequtils


var availStyles = @["ImGui Dark", "ImGui Light", "ImGui Classic", "Forest Green", "Sapphire", "Amethyst", "Amber Yellow", "Crimson Vesuvius", "Rose Quartz", "Cyberpunk", "Paper and Ink", "SETUP.EXE"]

var availStylesCSTRING*: seq[cstring] = availStyles.mapIt(it.cstring)

proc setupStyleGeometry*() =
  let style = igGetStyle()
  style.windowPadding     = ImVec2(x: 6f, y: 6f)
  style.windowRounding    = 0.0f
  #style.framePadding      = ImVec2(x: 5f, y: 2f)
  style.framePadding      = ImVec2(x: 10f, y: 6f)
  style.frameRounding     = 3.0f
  #style.itemSpacing       = ImVec2(x: 7f, y: 1f)
  style.itemSpacing       = ImVec2(x: 7f, y: 7f)
  style.itemInnerSpacing  = ImVec2(x: 1f, y: 1f)
  style.touchExtraPadding = ImVec2(x: 0f, y: 0f)
  style.indentSpacing     = 6.0f
  style.scrollbarSize     = 12.0f
  style.scrollbarRounding = 16.0f
  style.grabMinSize       = 20.0f
  style.grabRounding      = 2.0f
  style.frameBorderSize  = 0.0f
  style.windowBorderSize = 1.0f
  style.popupBorderSize = 0.0f
  style.displaySafeAreaPadding.y = 0
  style.tabBorderSize = 0
  style.selectableTextAlign = ImVec2(x: 0, y: 0.5f)
  style.windowTitleAlign = ImVec2(x: 0.5f, y: 0.75f)


proc makeResizeGripInvisible*() =
  let style = igGetStyle()
  style.colors[int(ImGuiCol.ResizeGrip)] = ImVec4(x: 0.00'f32, y: 0.00'f32, z: 0.00'f32, w: 0.00'f32)
  style.colors[int(ImGuiCol.ResizeGripHovered)] = ImVec4(x: 0.00'f32, y: 0.00'f32, z: 0.00'f32, w: 0.00'f32)
  style.colors[int(ImGuiCol.ResizeGripActive)] = ImVec4(x: 0.00'f32, y: 0.00'f32, z: 0.00'f32, w: 0.00'f32)

proc setupImGuiDarkStyle*() =
  igStyleColorsDark()

proc setupImGuiLightStyle*() =
  igStyleColorsLight()

proc setupImGuiClassicStyle*() =
  igStyleColorsClassic()


proc setupForestGreenStyle*() =
  let style = igGetStyle()

  # Text
  style.colors[int(ImGuiCol.Text)] = ImVec4(x: 0.85'f32, y: 0.90'f32, z: 0.85'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TextDisabled)] = ImVec4(x: 0.50'f32, y: 0.55'f32, z: 0.50'f32, w: 1.00'f32)

  # Backgrounds
  style.colors[int(ImGuiCol.WindowBg)] = ImVec4(x: 0.06'f32, y: 0.09'f32, z: 0.06'f32, w: 1.00'f32)   # Deep pine
  style.colors[int(ImGuiCol.ChildBg)] = ImVec4(x: 0.08'f32, y: 0.11'f32, z: 0.08'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.PopupBg)] = ImVec4(x: 0.07'f32, y: 0.10'f32, z: 0.07'f32, w: 0.96'f32)

  # Borders
  style.colors[int(ImGuiCol.Border)] = ImVec4(x: 0.18'f32, y: 0.28'f32, z: 0.18'f32, w: 0.80'f32)
  style.colors[int(ImGuiCol.BorderShadow)] = ImVec4(x: 0.00'f32, y: 0.00'f32, z: 0.00'f32, w: 0.00'f32)

  # Frames
  style.colors[int(ImGuiCol.FrameBg)] = ImVec4(x: 0.12'f32, y: 0.18'f32, z: 0.12'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.FrameBgHovered)] = ImVec4(x: 0.18'f32, y: 0.30'f32, z: 0.18'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.FrameBgActive)] = ImVec4(x: 0.24'f32, y: 0.42'f32, z: 0.24'f32, w: 1.00'f32)

  # Title Bars
  style.colors[int(ImGuiCol.TitleBg)] = ImVec4(x: 0.09'f32, y: 0.14'f32, z: 0.09'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TitleBgActive)] = ImVec4(x: 0.14'f32, y: 0.26'f32, z: 0.14'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TitleBgCollapsed)] = ImVec4(x: 0.05'f32, y: 0.08'f32, z: 0.05'f32, w: 1.00'f32)

  # Menus
  style.colors[int(ImGuiCol.MenuBarBg)] = ImVec4(x: 0.09'f32, y: 0.14'f32, z: 0.09'f32, w: 1.00'f32)

  # Scrollbars
  style.colors[int(ImGuiCol.ScrollbarBg)] = ImVec4(x: 0.05'f32, y: 0.08'f32, z: 0.05'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.ScrollbarGrab)] = ImVec4(x: 0.18'f32, y: 0.28'f32, z: 0.18'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.ScrollbarGrabHovered)] = ImVec4(x: 0.25'f32, y: 0.38'f32, z: 0.25'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.ScrollbarGrabActive)] = ImVec4(x: 0.32'f32, y: 0.48'f32, z: 0.32'f32, w: 1.00'f32)

  # Interactables
  style.colors[int(ImGuiCol.CheckMark)] = ImVec4(x: 0.45'f32, y: 0.75'f32, z: 0.45'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.SliderGrab)] = ImVec4(x: 0.35'f32, y: 0.55'f32, z: 0.35'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.SliderGrabActive)] = ImVec4(x: 0.45'f32, y: 0.70'f32, z: 0.45'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.Button)] = ImVec4(x: 0.18'f32, y: 0.35'f32, z: 0.18'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.ButtonHovered)] = ImVec4(x: 0.25'f32, y: 0.45'f32, z: 0.25'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.ButtonActive)] = ImVec4(x: 0.32'f32, y: 0.55'f32, z: 0.32'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.Header)] = ImVec4(x: 0.18'f32, y: 0.35'f32, z: 0.18'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.HeaderHovered)] = ImVec4(x: 0.25'f32, y: 0.45'f32, z: 0.25'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.HeaderActive)] = ImVec4(x: 0.32'f32, y: 0.55'f32, z: 0.32'f32, w: 1.00'f32)

  # Separators and Resizing
  style.colors[int(ImGuiCol.Separator)] = ImVec4(x: 0.18'f32, y: 0.28'f32, z: 0.18'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.SeparatorHovered)] = ImVec4(x: 0.25'f32, y: 0.45'f32, z: 0.25'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.SeparatorActive)] = ImVec4(x: 0.32'f32, y: 0.55'f32, z: 0.32'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.ResizeGrip)] = ImVec4(x: 0.18'f32, y: 0.35'f32, z: 0.18'f32, w: 0.80'f32)
  style.colors[int(ImGuiCol.ResizeGripHovered)] = ImVec4(x: 0.25'f32, y: 0.45'f32, z: 0.25'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.ResizeGripActive)] = ImVec4(x: 0.32'f32, y: 0.55'f32, z: 0.32'f32, w: 1.00'f32)

  # Tabs
  style.colors[int(ImGuiCol.Tab)] = ImVec4(x: 0.12'f32, y: 0.22'f32, z: 0.12'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TabHovered)] = ImVec4(x: 0.25'f32, y: 0.45'f32, z: 0.25'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TabActive)] = ImVec4(x: 0.20'f32, y: 0.38'f32, z: 0.20'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TabUnfocused)] = ImVec4(x: 0.08'f32, y: 0.15'f32, z: 0.08'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TabUnfocusedActive)] = ImVec4(x: 0.12'f32, y: 0.22'f32, z: 0.12'f32, w: 1.00'f32)

  # Plots
  style.colors[int(ImGuiCol.PlotLines)] = ImVec4(x: 0.40'f32, y: 0.70'f32, z: 0.40'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.PlotLinesHovered)] = ImVec4(x: 0.50'f32, y: 0.85'f32, z: 0.50'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.PlotHistogram)] = ImVec4(x: 0.40'f32, y: 0.70'f32, z: 0.40'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.PlotHistogramHovered)] = ImVec4(x: 0.50'f32, y: 0.85'f32, z: 0.50'f32, w: 1.00'f32)

  # Tables
  style.colors[int(ImGuiCol.TableHeaderBg)] = ImVec4(x: 0.12'f32, y: 0.22'f32, z: 0.12'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TableBorderStrong)] = ImVec4(x: 0.20'f32, y: 0.35'f32, z: 0.20'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TableBorderLight)] = ImVec4(x: 0.15'f32, y: 0.25'f32, z: 0.15'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TableRowBg)] = ImVec4(x: 0.00'f32, y: 0.00'f32, z: 0.00'f32, w: 0.00'f32)
  style.colors[int(ImGuiCol.TableRowBgAlt)] = ImVec4(x: 0.08'f32, y: 0.14'f32, z: 0.08'f32, w: 0.50'f32)

  # Misc
  style.colors[int(ImGuiCol.TextSelectedBg)] = ImVec4(x: 0.25'f32, y: 0.55'f32, z: 0.25'f32, w: 0.50'f32)
  style.colors[int(ImGuiCol.DragDropTarget)] = ImVec4(x: 0.60'f32, y: 0.90'f32, z: 0.60'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.NavHighlight)] = ImVec4(x: 0.40'f32, y: 0.80'f32, z: 0.40'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.NavWindowingHighlight)] = ImVec4(x: 0.85'f32, y: 0.90'f32, z: 0.85'f32, w: 0.70'f32)
  style.colors[int(ImGuiCol.NavWindowingDimBg)] = ImVec4(x: 0.10'f32, y: 0.15'f32, z: 0.10'f32, w: 0.50'f32)
  style.colors[int(ImGuiCol.ModalWindowDimBg)] = ImVec4(x: 0.05'f32, y: 0.08'f32, z: 0.05'f32, w: 0.60'f32)




proc setupSapphireStyle*() =
  let style = igGetStyle()

  # Text
  style.colors[int(ImGuiCol.Text)] = ImVec4(x: 0.90'f32, y: 0.93'f32, z: 0.97'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TextDisabled)] = ImVec4(x: 0.40'f32, y: 0.50'f32, z: 0.65'f32, w: 1.00'f32)

  # Backgrounds
  style.colors[int(ImGuiCol.WindowBg)] = ImVec4(x: 0.07'f32, y: 0.09'f32, z: 0.12'f32, w: 1.00'f32)   # Deep midnight
  style.colors[int(ImGuiCol.ChildBg)] = ImVec4(x: 0.09'f32, y: 0.12'f32, z: 0.16'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.PopupBg)] = ImVec4(x: 0.07'f32, y: 0.09'f32, z: 0.12'f32, w: 0.95'f32)

  # Borders
  style.colors[int(ImGuiCol.Border)] = ImVec4(x: 0.15'f32, y: 0.25'f32, z: 0.35'f32, w: 0.70'f32)
  style.colors[int(ImGuiCol.BorderShadow)] = ImVec4(x: 0.00'f32, y: 0.00'f32, z: 0.00'f32, w: 0.00'f32)

  # Frames
  style.colors[int(ImGuiCol.FrameBg)] = ImVec4(x: 0.12'f32, y: 0.18'f32, z: 0.26'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.FrameBgHovered)] = ImVec4(x: 0.18'f32, y: 0.28'f32, z: 0.40'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.FrameBgActive)] = ImVec4(x: 0.25'f32, y: 0.38'f32, z: 0.55'f32, w: 1.00'f32)

  # Title Bars
  style.colors[int(ImGuiCol.TitleBg)] = ImVec4(x: 0.09'f32, y: 0.12'f32, z: 0.18'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TitleBgActive)] = ImVec4(x: 0.14'f32, y: 0.22'f32, z: 0.35'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TitleBgCollapsed)] = ImVec4(x: 0.05'f32, y: 0.08'f32, z: 0.12'f32, w: 1.00'f32)

  # Menus
  style.colors[int(ImGuiCol.MenuBarBg)] = ImVec4(x: 0.12'f32, y: 0.16'f32, z: 0.22'f32, w: 1.00'f32)

  # Scrollbars
  style.colors[int(ImGuiCol.ScrollbarBg)] = ImVec4(x: 0.06'f32, y: 0.08'f32, z: 0.11'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.ScrollbarGrab)] = ImVec4(x: 0.20'f32, y: 0.32'f32, z: 0.48'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.ScrollbarGrabHovered)] = ImVec4(x: 0.28'f32, y: 0.42'f32, z: 0.60'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.ScrollbarGrabActive)] = ImVec4(x: 0.35'f32, y: 0.50'f32, z: 0.75'f32, w: 1.00'f32)

  # Interactables
  style.colors[int(ImGuiCol.CheckMark)] = ImVec4(x: 0.40'f32, y: 0.70'f32, z: 1.00'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.SliderGrab)] = ImVec4(x: 0.30'f32, y: 0.55'f32, z: 0.85'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.SliderGrabActive)] = ImVec4(x: 0.45'f32, y: 0.75'f32, z: 1.00'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.Button)] = ImVec4(x: 0.18'f32, y: 0.35'f32, z: 0.55'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.ButtonHovered)] = ImVec4(x: 0.25'f32, y: 0.48'f32, z: 0.75'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.ButtonActive)] = ImVec4(x: 0.35'f32, y: 0.60'f32, z: 0.90'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.Header)] = ImVec4(x: 0.18'f32, y: 0.35'f32, z: 0.55'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.HeaderHovered)] = ImVec4(x: 0.25'f32, y: 0.48'f32, z: 0.75'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.HeaderActive)] = ImVec4(x: 0.35'f32, y: 0.60'f32, z: 0.90'f32, w: 1.00'f32)

  # Tabs
  style.colors[int(ImGuiCol.Tab)] = ImVec4(x: 0.12'f32, y: 0.20'f32, z: 0.32'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TabHovered)] = ImVec4(x: 0.25'f32, y: 0.45'f32, z: 0.70'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TabActive)] = ImVec4(x: 0.18'f32, y: 0.35'f32, z: 0.55'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TabUnfocused)] = ImVec4(x: 0.08'f32, y: 0.12'f32, z: 0.18'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TabUnfocusedActive)] = ImVec4(x: 0.12'f32, y: 0.20'f32, z: 0.32'f32, w: 1.00'f32)

  # Tables
  style.colors[int(ImGuiCol.TableHeaderBg)] = ImVec4(x: 0.15'f32, y: 0.25'f32, z: 0.40'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TableBorderStrong)] = ImVec4(x: 0.20'f32, y: 0.35'f32, z: 0.55'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TableBorderLight)] = ImVec4(x: 0.15'f32, y: 0.25'f32, z: 0.40'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TableRowBg)] = ImVec4(x: 0.00'f32, y: 0.00'f32, z: 0.00'f32, w: 0.00'f32)   # transparent
  style.colors[int(ImGuiCol.TableRowBgAlt)] = ImVec4(x: 1.00'f32, y: 1.00'f32, z: 1.00'f32, w: 0.05'f32)

  # Misc
  style.colors[int(ImGuiCol.TextSelectedBg)] = ImVec4(x: 0.30'f32, y: 0.55'f32, z: 0.85'f32, w: 0.40'f32)
  style.colors[int(ImGuiCol.DragDropTarget)] = ImVec4(x: 0.50'f32, y: 0.80'f32, z: 1.00'f32, w: 0.90'f32)
  style.colors[int(ImGuiCol.NavHighlight)] = ImVec4(x: 0.40'f32, y: 0.70'f32, z: 1.00'f32, w: 1.00'f32)

  style.colors[int(ImGuiCol.Separator)] = ImVec4(x: 0.15'f32, y: 0.25'f32, z: 0.35'f32, w: 0.70'f32)
  style.colors[int(ImGuiCol.SeparatorHovered)] = ImVec4(x: 0.25'f32, y: 0.48'f32, z: 0.75'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.SeparatorActive)] = ImVec4(x: 0.35'f32, y: 0.60'f32, z: 0.90'f32, w: 1.00'f32)


proc setupAmberYellowStyle*() =
  let style = igGetStyle()

  # Text
  style.colors[int(ImGuiCol.Text)] = ImVec4(x: 1.00'f32, y: 0.95'f32, z: 0.80'f32, w: 1.00'f32)   # Soft cream‑yellow
  style.colors[int(ImGuiCol.TextDisabled)] = ImVec4(x: 0.50'f32, y: 0.45'f32, z: 0.30'f32, w: 1.00'f32)

  # Backgrounds
  style.colors[int(ImGuiCol.WindowBg)] = ImVec4(x: 0.07'f32, y: 0.07'f32, z: 0.06'f32, w: 1.00'f32)   # Near black
  style.colors[int(ImGuiCol.ChildBg)] = ImVec4(x: 0.09'f32, y: 0.09'f32, z: 0.08'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.PopupBg)] = ImVec4(x: 0.07'f32, y: 0.07'f32, z: 0.06'f32, w: 0.96'f32)

  # Borders
  style.colors[int(ImGuiCol.Border)] = ImVec4(x: 0.30'f32, y: 0.25'f32, z: 0.10'f32, w: 0.80'f32)
  style.colors[int(ImGuiCol.BorderShadow)] = ImVec4(x: 0.00'f32, y: 0.00'f32, z: 0.00'f32, w: 0.00'f32)

  # Frames
  style.colors[int(ImGuiCol.FrameBg)] = ImVec4(x: 0.15'f32, y: 0.14'f32, z: 0.10'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.FrameBgHovered)] = ImVec4(x: 0.25'f32, y: 0.22'f32, z: 0.12'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.FrameBgActive)] = ImVec4(x: 0.35'f32, y: 0.30'f32, z: 0.15'f32, w: 1.00'f32)

  # Title Bars
  style.colors[int(ImGuiCol.TitleBg)] = ImVec4(x: 0.12'f32, y: 0.11'f32, z: 0.08'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TitleBgActive)] = ImVec4(x: 0.20'f32, y: 0.18'f32, z: 0.10'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TitleBgCollapsed)] = ImVec4(x: 0.05'f32, y: 0.05'f32, z: 0.04'f32, w: 1.00'f32)

  # Menus
  style.colors[int(ImGuiCol.MenuBarBg)] = ImVec4(x: 0.12'f32, y: 0.11'f32, z: 0.08'f32, w: 1.00'f32)

  # Scrollbars
  style.colors[int(ImGuiCol.ScrollbarBg)] = ImVec4(x: 0.05'f32, y: 0.05'f32, z: 0.04'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.ScrollbarGrab)] = ImVec4(x: 0.35'f32, y: 0.30'f32, z: 0.10'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.ScrollbarGrabHovered)] = ImVec4(x: 0.45'f32, y: 0.40'f32, z: 0.15'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.ScrollbarGrabActive)] = ImVec4(x: 0.55'f32, y: 0.50'f32, z: 0.20'f32, w: 1.00'f32)

  # Interactables
  style.colors[int(ImGuiCol.CheckMark)] = ImVec4(x: 0.95'f32, y: 0.80'f32, z: 0.10'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.SliderGrab)] = ImVec4(x: 0.70'f32, y: 0.60'f32, z: 0.10'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.SliderGrabActive)] = ImVec4(x: 0.95'f32, y: 0.80'f32, z: 0.10'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.Button)] = ImVec4(x: 0.30'f32, y: 0.25'f32, z: 0.05'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.ButtonHovered)] = ImVec4(x: 0.45'f32, y: 0.38'f32, z: 0.10'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.ButtonActive)] = ImVec4(x: 0.60'f32, y: 0.50'f32, z: 0.15'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.Header)] = ImVec4(x: 0.30'f32, y: 0.25'f32, z: 0.05'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.HeaderHovered)] = ImVec4(x: 0.45'f32, y: 0.38'f32, z: 0.10'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.HeaderActive)] = ImVec4(x: 0.60'f32, y: 0.50'f32, z: 0.15'f32, w: 1.00'f32)

  # Tabs
  style.colors[int(ImGuiCol.Tab)] = ImVec4(x: 0.15'f32, y: 0.14'f32, z: 0.10'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TabHovered)] = ImVec4(x: 0.45'f32, y: 0.38'f32, z: 0.10'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TabActive)] = ImVec4(x: 0.35'f32, y: 0.30'f32, z: 0.10'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TabUnfocused)] = ImVec4(x: 0.08'f32, y: 0.08'f32, z: 0.07'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TabUnfocusedActive)] = ImVec4(x: 0.15'f32, y: 0.14'f32, z: 0.10'f32, w: 1.00'f32)

  # Tables
  style.colors[int(ImGuiCol.TableHeaderBg)] = ImVec4(x: 0.18'f32, y: 0.16'f32, z: 0.10'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TableBorderStrong)] = ImVec4(x: 0.35'f32, y: 0.30'f32, z: 0.15'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TableBorderLight)] = ImVec4(x: 0.25'f32, y: 0.20'f32, z: 0.10'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TableRowBg)] = ImVec4(x: 0.00'f32, y: 0.00'f32, z: 0.00'f32, w: 0.00'f32)   # transparent
  style.colors[int(ImGuiCol.TableRowBgAlt)] = ImVec4(x: 1.00'f32, y: 1.00'f32, z: 1.00'f32, w: 0.03'f32)

  # Misc
  style.colors[int(ImGuiCol.TextSelectedBg)] = ImVec4(x: 0.95'f32, y: 0.80'f32, z: 0.10'f32, w: 0.25'f32)
  style.colors[int(ImGuiCol.DragDropTarget)] = ImVec4(x: 1.00'f32, y: 0.85'f32, z: 0.00'f32, w: 0.90'f32)
  style.colors[int(ImGuiCol.NavHighlight)] = ImVec4(x: 0.95'f32, y: 0.80'f32, z: 0.10'f32, w: 1.00'f32)

  style.colors[int(ImGuiCol.Separator)] = ImVec4(x: 0.30'f32, y: 0.25'f32, z: 0.10'f32, w: 0.80'f32)
  style.colors[int(ImGuiCol.SeparatorHovered)] = ImVec4(x: 0.45'f32, y: 0.38'f32, z: 0.10'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.SeparatorActive)] = ImVec4(x: 0.60'f32, y: 0.50'f32, z: 0.15'f32, w: 1.00'f32)


proc setupAmethystStyle*() =
  let style = igGetStyle()

  # Text
  style.colors[int(ImGuiCol.Text)] = ImVec4(x: 0.92'f32, y: 0.90'f32, z: 0.95'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TextDisabled)] = ImVec4(x: 0.55'f32, y: 0.50'f32, z: 0.60'f32, w: 1.00'f32)

  # Backgrounds
  style.colors[int(ImGuiCol.WindowBg)] = ImVec4(x: 0.09'f32, y: 0.07'f32, z: 0.12'f32, w: 1.00'f32)   # Deep charcoal‑purple
  style.colors[int(ImGuiCol.ChildBg)] = ImVec4(x: 0.11'f32, y: 0.09'f32, z: 0.14'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.PopupBg)] = ImVec4(x: 0.09'f32, y: 0.07'f32, z: 0.12'f32, w: 0.96'f32)

  # Borders
  style.colors[int(ImGuiCol.Border)] = ImVec4(x: 0.25'f32, y: 0.20'f32, z: 0.35'f32, w: 0.80'f32)
  style.colors[int(ImGuiCol.BorderShadow)] = ImVec4(x: 0.00'f32, y: 0.00'f32, z: 0.00'f32, w: 0.00'f32)

  # Frames
  style.colors[int(ImGuiCol.FrameBg)] = ImVec4(x: 0.15'f32, y: 0.12'f32, z: 0.22'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.FrameBgHovered)] = ImVec4(x: 0.25'f32, y: 0.20'f32, z: 0.38'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.FrameBgActive)] = ImVec4(x: 0.35'f32, y: 0.25'f32, z: 0.55'f32, w: 1.00'f32)

  # Title Bars
  style.colors[int(ImGuiCol.TitleBg)] = ImVec4(x: 0.12'f32, y: 0.09'f32, z: 0.18'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TitleBgActive)] = ImVec4(x: 0.20'f32, y: 0.14'f32, z: 0.32'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TitleBgCollapsed)] = ImVec4(x: 0.07'f32, y: 0.05'f32, z: 0.10'f32, w: 1.00'f32)

  # Menus
  style.colors[int(ImGuiCol.MenuBarBg)] = ImVec4(x: 0.12'f32, y: 0.09'f32, z: 0.18'f32, w: 1.00'f32)

  # Scrollbars
  style.colors[int(ImGuiCol.ScrollbarBg)] = ImVec4(x: 0.07'f32, y: 0.05'f32, z: 0.10'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.ScrollbarGrab)] = ImVec4(x: 0.25'f32, y: 0.20'f32, z: 0.35'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.ScrollbarGrabHovered)] = ImVec4(x: 0.35'f32, y: 0.30'f32, z: 0.50'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.ScrollbarGrabActive)] = ImVec4(x: 0.45'f32, y: 0.40'f32, z: 0.65'f32, w: 1.00'f32)

  # Interactables
  style.colors[int(ImGuiCol.CheckMark)] = ImVec4(x: 0.65'f32, y: 0.45'f32, z: 0.95'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.SliderGrab)] = ImVec4(x: 0.50'f32, y: 0.35'f32, z: 0.75'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.SliderGrabActive)] = ImVec4(x: 0.65'f32, y: 0.45'f32, z: 0.95'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.Button)] = ImVec4(x: 0.25'f32, y: 0.20'f32, z: 0.40'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.ButtonHovered)] = ImVec4(x: 0.38'f32, y: 0.28'f32, z: 0.62'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.ButtonActive)] = ImVec4(x: 0.50'f32, y: 0.35'f32, z: 0.80'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.Header)] = ImVec4(x: 0.25'f32, y: 0.20'f32, z: 0.40'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.HeaderHovered)] = ImVec4(x: 0.38'f32, y: 0.28'f32, z: 0.62'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.HeaderActive)] = ImVec4(x: 0.50'f32, y: 0.35'f32, z: 0.80'f32, w: 1.00'f32)

  # Tabs
  style.colors[int(ImGuiCol.Tab)] = ImVec4(x: 0.15'f32, y: 0.12'f32, z: 0.25'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TabHovered)] = ImVec4(x: 0.38'f32, y: 0.28'f32, z: 0.62'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TabActive)] = ImVec4(x: 0.28'f32, y: 0.20'f32, z: 0.45'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TabUnfocused)] = ImVec4(x: 0.10'f32, y: 0.08'f32, z: 0.15'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TabUnfocusedActive)] = ImVec4(x: 0.15'f32, y: 0.12'f32, z: 0.25'f32, w: 1.00'f32)

  # Tables
  style.colors[int(ImGuiCol.TableHeaderBg)] = ImVec4(x: 0.18'f32, y: 0.15'f32, z: 0.28'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TableBorderStrong)] = ImVec4(x: 0.25'f32, y: 0.20'f32, z: 0.40'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TableBorderLight)] = ImVec4(x: 0.20'f32, y: 0.15'f32, z: 0.30'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TableRowBg)] = ImVec4(x: 0.00'f32, y: 0.00'f32, z: 0.00'f32, w: 0.00'f32)   # default transparent
  style.colors[int(ImGuiCol.TableRowBgAlt)] = ImVec4(x: 1.00'f32, y: 1.00'f32, z: 1.00'f32, w: 0.04'f32)

  # Misc
  style.colors[int(ImGuiCol.TextSelectedBg)] = ImVec4(x: 0.50'f32, y: 0.35'f32, z: 0.80'f32, w: 0.35'f32)
  style.colors[int(ImGuiCol.DragDropTarget)] = ImVec4(x: 0.80'f32, y: 0.65'f32, z: 1.00'f32, w: 0.95'f32)
  style.colors[int(ImGuiCol.NavHighlight)] = ImVec4(x: 0.60'f32, y: 0.45'f32, z: 0.90'f32, w: 1.00'f32)

  style.colors[int(ImGuiCol.Separator)] = ImVec4(x: 0.25'f32, y: 0.20'f32, z: 0.35'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.SeparatorHovered)] = ImVec4(x: 0.38'f32, y: 0.28'f32, z: 0.62'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.SeparatorActive)] = ImVec4(x: 0.50'f32, y: 0.35'f32, z: 0.80'f32, w: 1.00'f32)



proc setupCrimsonVesuviusStyle*() =
  let style = igGetStyle()

  # Text
  style.colors[int(ImGuiCol.Text)] = ImVec4(x: 1.00'f32, y: 0.90'f32, z: 0.90'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TextDisabled)] = ImVec4(x: 0.50'f32, y: 0.40'f32, z: 0.40'f32, w: 1.00'f32)

  # Backgrounds
  style.colors[int(ImGuiCol.WindowBg)] = ImVec4(x: 0.08'f32, y: 0.07'f32, z: 0.07'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.ChildBg)] = ImVec4(x: 0.10'f32, y: 0.09'f32, z: 0.09'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.PopupBg)] = ImVec4(x: 0.08'f32, y: 0.07'f32, z: 0.07'f32, w: 0.96'f32)

  # Borders
  style.colors[int(ImGuiCol.Border)] = ImVec4(x: 0.25'f32, y: 0.15'f32, z: 0.15'f32, w: 0.80'f32)
  style.colors[int(ImGuiCol.BorderShadow)] = ImVec4(x: 0.00'f32, y: 0.00'f32, z: 0.00'f32, w: 0.00'f32)

  # Frames
  style.colors[int(ImGuiCol.FrameBg)] = ImVec4(x: 0.15'f32, y: 0.10'f32, z: 0.10'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.FrameBgHovered)] = ImVec4(x: 0.25'f32, y: 0.15'f32, z: 0.15'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.FrameBgActive)] = ImVec4(x: 0.35'f32, y: 0.20'f32, z: 0.20'f32, w: 1.00'f32)

  # Title Bars
  style.colors[int(ImGuiCol.TitleBg)] = ImVec4(x: 0.12'f32, y: 0.08'f32, z: 0.08'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TitleBgActive)] = ImVec4(x: 0.25'f32, y: 0.10'f32, z: 0.10'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TitleBgCollapsed)] = ImVec4(x: 0.05'f32, y: 0.05'f32, z: 0.05'f32, w: 1.00'f32)

  # Menus
  style.colors[int(ImGuiCol.MenuBarBg)] = ImVec4(x: 0.12'f32, y: 0.08'f32, z: 0.08'f32, w: 1.00'f32)

  # Scrollbars
  style.colors[int(ImGuiCol.ScrollbarBg)] = ImVec4(x: 0.05'f32, y: 0.05'f32, z: 0.05'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.ScrollbarGrab)] = ImVec4(x: 0.25'f32, y: 0.12'f32, z: 0.12'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.ScrollbarGrabHovered)] = ImVec4(x: 0.35'f32, y: 0.15'f32, z: 0.15'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.ScrollbarGrabActive)] = ImVec4(x: 0.45'f32, y: 0.20'f32, z: 0.20'f32, w: 1.00'f32)

  # Interactables
  style.colors[int(ImGuiCol.CheckMark)] = ImVec4(x: 0.85'f32, y: 0.15'f32, z: 0.15'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.SliderGrab)] = ImVec4(x: 0.60'f32, y: 0.12'f32, z: 0.12'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.SliderGrabActive)] = ImVec4(x: 0.85'f32, y: 0.15'f32, z: 0.15'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.Button)] = ImVec4(x: 0.30'f32, y: 0.12'f32, z: 0.12'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.ButtonHovered)] = ImVec4(x: 0.50'f32, y: 0.18'f32, z: 0.18'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.ButtonActive)] = ImVec4(x: 0.70'f32, y: 0.25'f32, z: 0.25'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.Header)] = ImVec4(x: 0.30'f32, y: 0.12'f32, z: 0.12'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.HeaderHovered)] = ImVec4(x: 0.50'f32, y: 0.18'f32, z: 0.18'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.HeaderActive)] = ImVec4(x: 0.70'f32, y: 0.25'f32, z: 0.25'f32, w: 1.00'f32)

  # Tabs
  style.colors[int(ImGuiCol.Tab)] = ImVec4(x: 0.15'f32, y: 0.10'f32, z: 0.10'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TabHovered)] = ImVec4(x: 0.50'f32, y: 0.18'f32, z: 0.18'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TabActive)] = ImVec4(x: 0.35'f32, y: 0.12'f32, z: 0.12'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TabUnfocused)] = ImVec4(x: 0.10'f32, y: 0.08'f32, z: 0.08'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TabUnfocusedActive)] = ImVec4(x: 0.15'f32, y: 0.10'f32, z: 0.10'f32, w: 1.00'f32)

  # Separators and Resizing
  style.colors[int(ImGuiCol.Separator)] = ImVec4(x: 0.25'f32, y: 0.15'f32, z: 0.15'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.SeparatorHovered)] = ImVec4(x: 0.50'f32, y: 0.18'f32, z: 0.18'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.SeparatorActive)] = ImVec4(x: 0.70'f32, y: 0.25'f32, z: 0.25'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.ResizeGrip)] = ImVec4(x: 0.25'f32, y: 0.12'f32, z: 0.12'f32, w: 0.80'f32)
  style.colors[int(ImGuiCol.ResizeGripHovered)] = ImVec4(x: 0.50'f32, y: 0.18'f32, z: 0.18'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.ResizeGripActive)] = ImVec4(x: 0.70'f32, y: 0.25'f32, z: 0.25'f32, w: 1.00'f32)

  # Tables
  style.colors[int(ImGuiCol.TableHeaderBg)] = ImVec4(x: 0.15'f32, y: 0.10'f32, z: 0.10'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TableBorderStrong)] = ImVec4(x: 0.25'f32, y: 0.15'f32, z: 0.15'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TableBorderLight)] = ImVec4(x: 0.20'f32, y: 0.12'f32, z: 0.12'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TableRowBg)] = ImVec4(x: 0.00'f32, y: 0.00'f32, z: 0.00'f32, w: 0.00'f32)
  style.colors[int(ImGuiCol.TableRowBgAlt)] = ImVec4(x: 1.00'f32, y: 1.00'f32, z: 1.00'f32, w: 0.04'f32)

  # Misc
  style.colors[int(ImGuiCol.PlotLines)] = ImVec4(x: 0.85'f32, y: 0.20'f32, z: 0.20'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.PlotLinesHovered)] = ImVec4(x: 1.00'f32, y: 0.30'f32, z: 0.30'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.PlotHistogram)] = ImVec4(x: 0.85'f32, y: 0.20'f32, z: 0.20'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.PlotHistogramHovered)] = ImVec4(x: 1.00'f32, y: 0.30'f32, z: 0.30'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TextSelectedBg)] = ImVec4(x: 0.85'f32, y: 0.15'f32, z: 0.15'f32, w: 0.35'f32)
  style.colors[int(ImGuiCol.NavHighlight)] = ImVec4(x: 0.85'f32, y: 0.15'f32, z: 0.15'f32, w: 1.00'f32)



proc setupRoseQuartzStyle*() =
  let style = igGetStyle()

  # Text
  style.colors[int(ImGuiCol.Text)] = ImVec4(x: 0.95'f32, y: 0.90'f32, z: 0.95'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TextDisabled)] = ImVec4(x: 0.55'f32, y: 0.45'f32, z: 0.55'f32, w: 1.00'f32)

  # Backgrounds
  style.colors[int(ImGuiCol.WindowBg)] = ImVec4(x: 0.12'f32, y: 0.10'f32, z: 0.12'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.ChildBg)] = ImVec4(x: 0.14'f32, y: 0.12'f32, z: 0.14'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.PopupBg)] = ImVec4(x: 0.10'f32, y: 0.08'f32, z: 0.10'f32, w: 0.96'f32)

  # Borders
  style.colors[int(ImGuiCol.Border)] = ImVec4(x: 0.35'f32, y: 0.25'f32, z: 0.35'f32, w: 0.50'f32)
  style.colors[int(ImGuiCol.BorderShadow)] = ImVec4(x: 0.00'f32, y: 0.00'f32, z: 0.00'f32, w: 0.00'f32)

  # Frames
  style.colors[int(ImGuiCol.FrameBg)] = ImVec4(x: 0.20'f32, y: 0.15'f32, z: 0.20'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.FrameBgHovered)] = ImVec4(x: 0.30'f32, y: 0.22'f32, z: 0.30'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.FrameBgActive)] = ImVec4(x: 0.40'f32, y: 0.28'f32, z: 0.40'f32, w: 1.00'f32)

  # Title Bars
  style.colors[int(ImGuiCol.TitleBg)] = ImVec4(x: 0.15'f32, y: 0.10'f32, z: 0.15'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TitleBgActive)] = ImVec4(x: 0.25'f32, y: 0.15'f32, z: 0.25'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TitleBgCollapsed)] = ImVec4(x: 0.08'f32, y: 0.06'f32, z: 0.08'f32, w: 1.00'f32)

  # Menus
  style.colors[int(ImGuiCol.MenuBarBg)] = ImVec4(x: 0.15'f32, y: 0.10'f32, z: 0.15'f32, w: 1.00'f32)

  # Scrollbars
  style.colors[int(ImGuiCol.ScrollbarBg)] = ImVec4(x: 0.08'f32, y: 0.06'f32, z: 0.08'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.ScrollbarGrab)] = ImVec4(x: 0.40'f32, y: 0.25'f32, z: 0.40'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.ScrollbarGrabHovered)] = ImVec4(x: 0.55'f32, y: 0.35'f32, z: 0.55'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.ScrollbarGrabActive)] = ImVec4(x: 0.70'f32, y: 0.45'f32, z: 0.70'f32, w: 1.00'f32)

  # Interactables
  style.colors[int(ImGuiCol.CheckMark)] = ImVec4(x: 0.95'f32, y: 0.60'f32, z: 0.75'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.SliderGrab)] = ImVec4(x: 0.85'f32, y: 0.50'f32, z: 0.65'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.SliderGrabActive)] = ImVec4(x: 0.95'f32, y: 0.60'f32, z: 0.75'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.Button)] = ImVec4(x: 0.45'f32, y: 0.25'f32, z: 0.35'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.ButtonHovered)] = ImVec4(x: 0.65'f32, y: 0.35'f32, z: 0.50'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.ButtonActive)] = ImVec4(x: 0.85'f32, y: 0.45'f32, z: 0.65'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.Header)] = ImVec4(x: 0.45'f32, y: 0.25'f32, z: 0.35'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.HeaderHovered)] = ImVec4(x: 0.55'f32, y: 0.30'f32, z: 0.45'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.HeaderActive)] = ImVec4(x: 0.65'f32, y: 0.35'f32, z: 0.55'f32, w: 1.00'f32)

  # Tabs
  style.colors[int(ImGuiCol.Tab)] = ImVec4(x: 0.20'f32, y: 0.15'f32, z: 0.20'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TabHovered)] = ImVec4(x: 0.65'f32, y: 0.35'f32, z: 0.50'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TabActive)] = ImVec4(x: 0.45'f32, y: 0.25'f32, z: 0.35'f32, w: 1.00'f32)

  # Separators and Resizing
  style.colors[int(ImGuiCol.Separator)] = ImVec4(x: 0.35'f32, y: 0.25'f32, z: 0.35'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.SeparatorHovered)] = ImVec4(x: 0.65'f32, y: 0.35'f32, z: 0.50'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.SeparatorActive)] = ImVec4(x: 0.85'f32, y: 0.45'f32, z: 0.65'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.ResizeGrip)] = ImVec4(x: 0.40'f32, y: 0.25'f32, z: 0.40'f32, w: 0.80'f32)
  style.colors[int(ImGuiCol.ResizeGripHovered)] = ImVec4(x: 0.65'f32, y: 0.35'f32, z: 0.50'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.ResizeGripActive)] = ImVec4(x: 0.85'f32, y: 0.45'f32, z: 0.65'f32, w: 1.00'f32)

  # Tables
  style.colors[int(ImGuiCol.TableHeaderBg)] = ImVec4(x: 0.20'f32, y: 0.15'f32, z: 0.20'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TableBorderStrong)] = ImVec4(x: 0.35'f32, y: 0.25'f32, z: 0.35'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TableBorderLight)] = ImVec4(x: 0.45'f32, y: 0.30'f32, z: 0.45'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TableRowBg)] = ImVec4(x: 0.00'f32, y: 0.00'f32, z: 0.00'f32, w: 0.00'f32)
  style.colors[int(ImGuiCol.TableRowBgAlt)] = ImVec4(x: 1.00'f32, y: 1.00'f32, z: 1.00'f32, w: 0.04'f32)

  # Misc
  style.colors[int(ImGuiCol.PlotLines)] = ImVec4(x: 0.85'f32, y: 0.50'f32, z: 0.65'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.PlotLinesHovered)] = ImVec4(x: 0.95'f32, y: 0.60'f32, z: 0.75'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.PlotHistogram)] = ImVec4(x: 0.85'f32, y: 0.50'f32, z: 0.65'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.PlotHistogramHovered)] = ImVec4(x: 0.95'f32, y: 0.60'f32, z: 0.75'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TextSelectedBg)] = ImVec4(x: 0.95'f32, y: 0.60'f32, z: 0.75'f32, w: 0.35'f32)
  style.colors[int(ImGuiCol.NavHighlight)] = ImVec4(x: 0.95'f32, y: 0.60'f32, z: 0.75'f32, w: 1.00'f32)



proc setupCyberpunkStyle*() =
  let style = igGetStyle()

  # Text
  style.colors[int(ImGuiCol.Text)] = ImVec4(x: 0.00'f32, y: 1.00'f32, z: 0.62'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TextDisabled)] = ImVec4(x: 0.20'f32, y: 0.40'f32, z: 0.35'f32, w: 1.00'f32)

  # Backgrounds
  style.colors[int(ImGuiCol.WindowBg)] = ImVec4(x: 0.02'f32, y: 0.02'f32, z: 0.04'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.ChildBg)] = ImVec4(x: 0.02'f32, y: 0.02'f32, z: 0.04'f32, w: 0.00'f32)
  style.colors[int(ImGuiCol.PopupBg)] = ImVec4(x: 0.02'f32, y: 0.02'f32, z: 0.04'f32, w: 0.98'f32)

  # Borders (The "Glow" look)
  style.colors[int(ImGuiCol.Border)] = ImVec4(x: 1.00'f32, y: 0.00'f32, z: 0.25'f32, w: 0.60'f32)
  style.colors[int(ImGuiCol.BorderShadow)] = ImVec4(x: 1.00'f32, y: 0.00'f32, z: 0.25'f32, w: 0.20'f32)

  # Frames
  style.colors[int(ImGuiCol.FrameBg)] = ImVec4(x: 0.05'f32, y: 0.05'f32, z: 0.10'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.FrameBgHovered)] = ImVec4(x: 1.00'f32, y: 0.00'f32, z: 0.25'f32, w: 0.20'f32)
  style.colors[int(ImGuiCol.FrameBgActive)] = ImVec4(x: 1.00'f32, y: 0.00'f32, z: 0.25'f32, w: 0.40'f32)

  # Title Bars
  style.colors[int(ImGuiCol.TitleBg)] = ImVec4(x: 0.02'f32, y: 0.02'f32, z: 0.04'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TitleBgActive)] = ImVec4(x: 0.05'f32, y: 0.05'f32, z: 0.10'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TitleBgCollapsed)] = ImVec4(x: 0.02'f32, y: 0.02'f32, z: 0.04'f32, w: 1.00'f32)

  # Menus
  style.colors[int(ImGuiCol.MenuBarBg)] = ImVec4(x: 0.05'f32, y: 0.05'f32, z: 0.10'f32, w: 1.00'f32)

  # Scrollbars
  style.colors[int(ImGuiCol.ScrollbarBg)] = ImVec4(x: 0.02'f32, y: 0.02'f32, z: 0.04'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.ScrollbarGrab)] = ImVec4(x: 1.00'f32, y: 0.93'f32, z: 0.04'f32, w: 0.60'f32)
  style.colors[int(ImGuiCol.ScrollbarGrabHovered)] = ImVec4(x: 1.00'f32, y: 0.93'f32, z: 0.04'f32, w: 0.80'f32)
  style.colors[int(ImGuiCol.ScrollbarGrabActive)] = ImVec4(x: 1.00'f32, y: 0.93'f32, z: 0.04'f32, w: 1.00'f32)

  # Interactables
  style.colors[int(ImGuiCol.CheckMark)] = ImVec4(x: 1.00'f32, y: 0.93'f32, z: 0.04'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.SliderGrab)] = ImVec4(x: 1.00'f32, y: 0.00'f32, z: 0.25'f32, w: 0.80'f32)
  style.colors[int(ImGuiCol.SliderGrabActive)] = ImVec4(x: 1.00'f32, y: 0.00'f32, z: 0.25'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.Button)] = ImVec4(x: 0.00'f32, y: 1.00'f32, z: 0.62'f32, w: 0.20'f32)
  style.colors[int(ImGuiCol.ButtonHovered)] = ImVec4(x: 0.00'f32, y: 1.00'f32, z: 0.62'f32, w: 0.50'f32)
  style.colors[int(ImGuiCol.ButtonActive)] = ImVec4(x: 0.00'f32, y: 1.00'f32, z: 0.62'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.Header)] = ImVec4(x: 1.00'f32, y: 0.00'f32, z: 0.25'f32, w: 0.30'f32)
  style.colors[int(ImGuiCol.HeaderHovered)] = ImVec4(x: 1.00'f32, y: 0.00'f32, z: 0.25'f32, w: 0.50'f32)
  style.colors[int(ImGuiCol.HeaderActive)] = ImVec4(x: 1.00'f32, y: 0.00'f32, z: 0.25'f32, w: 1.00'f32)

  # Tabs
  style.colors[int(ImGuiCol.Tab)] = ImVec4(x: 0.05'f32, y: 0.05'f32, z: 0.10'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TabHovered)] = ImVec4(x: 1.00'f32, y: 0.00'f32, z: 0.25'f32, w: 0.80'f32)
  style.colors[int(ImGuiCol.TabActive)] = ImVec4(x: 0.80'f32, y: 0.00'f32, z: 0.20'f32, w: 1.00'f32)

  # Separators and Resizing
  style.colors[int(ImGuiCol.Separator)] = ImVec4(x: 1.00'f32, y: 0.00'f32, z: 0.25'f32, w: 0.60'f32)
  style.colors[int(ImGuiCol.SeparatorHovered)] = ImVec4(x: 1.00'f32, y: 0.00'f32, z: 0.25'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.SeparatorActive)] = ImVec4(x: 1.00'f32, y: 0.00'f32, z: 0.25'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.ResizeGrip)] = ImVec4(x: 0.00'f32, y: 1.00'f32, z: 0.62'f32, w: 0.40'f32)
  style.colors[int(ImGuiCol.ResizeGripHovered)] = ImVec4(x: 0.00'f32, y: 1.00'f32, z: 0.62'f32, w: 0.70'f32)
  style.colors[int(ImGuiCol.ResizeGripActive)] = ImVec4(x: 0.00'f32, y: 1.00'f32, z: 0.62'f32, w: 1.00'f32)

  # Tables
  style.colors[int(ImGuiCol.TableHeaderBg)] = ImVec4(x: 0.05'f32, y: 0.05'f32, z: 0.10'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TableBorderStrong)] = ImVec4(x: 1.00'f32, y: 0.00'f32, z: 0.25'f32, w: 0.80'f32)
  style.colors[int(ImGuiCol.TableBorderLight)] = ImVec4(x: 1.00'f32, y: 0.00'f32, z: 0.25'f32, w: 0.40'f32)
  style.colors[int(ImGuiCol.TableRowBg)] = ImVec4(x: 0.00'f32, y: 0.00'f32, z: 0.00'f32, w: 0.00'f32)
  style.colors[int(ImGuiCol.TableRowBgAlt)] = ImVec4(x: 1.00'f32, y: 1.00'f32, z: 1.00'f32, w: 0.03'f32)

  # Misc
  style.colors[int(ImGuiCol.PlotLines)] = ImVec4(x: 0.00'f32, y: 1.00'f32, z: 0.62'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.PlotLinesHovered)] = ImVec4(x: 0.00'f32, y: 1.00'f32, z: 0.62'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.PlotHistogram)] = ImVec4(x: 1.00'f32, y: 0.93'f32, z: 0.04'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.PlotHistogramHovered)] = ImVec4(x: 1.00'f32, y: 0.93'f32, z: 0.04'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TextSelectedBg)] = ImVec4(x: 1.00'f32, y: 0.93'f32, z: 0.04'f32, w: 0.30'f32)
  style.colors[int(ImGuiCol.NavHighlight)] = ImVec4(x: 1.00'f32, y: 0.00'f32, z: 0.25'f32, w: 1.00'f32)




proc setupPaperAndInkStyle*() =
  let style = igGetStyle()

  # Text
  style.colors[int(ImGuiCol.Text)] = ImVec4(x: 0.12'f32, y: 0.12'f32, z: 0.12'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TextDisabled)] = ImVec4(x: 0.55'f32, y: 0.55'f32, z: 0.55'f32, w: 1.00'f32)

  # Backgrounds
  style.colors[int(ImGuiCol.WindowBg)] = ImVec4(x: 0.96'f32, y: 0.96'f32, z: 0.94'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.ChildBg)] = ImVec4(x: 0.00'f32, y: 0.00'f32, z: 0.00'f32, w: 0.03'f32)
  style.colors[int(ImGuiCol.PopupBg)] = ImVec4(x: 1.00'f32, y: 1.00'f32, z: 1.00'f32, w: 1.00'f32)

  # Borders & Separators
  style.colors[int(ImGuiCol.Border)] = ImVec4(x: 0.75'f32, y: 0.75'f32, z: 0.72'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.BorderShadow)] = ImVec4(x: 0.00'f32, y: 0.00'f32, z: 0.00'f32, w: 0.00'f32)
  style.colors[int(ImGuiCol.Separator)] = ImVec4(x: 0.80'f32, y: 0.80'f32, z: 0.78'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.SeparatorHovered)] = ImVec4(x: 0.17'f32, y: 0.34'f32, z: 0.59'f32, w: 0.78'f32)
  style.colors[int(ImGuiCol.SeparatorActive)] = ImVec4(x: 0.17'f32, y: 0.34'f32, z: 0.59'f32, w: 0.35'f32)

  # Frames
  style.colors[int(ImGuiCol.FrameBg)] = ImVec4(x: 1.00'f32, y: 1.00'f32, z: 1.00'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.FrameBgHovered)] = ImVec4(x: 0.90'f32, y: 0.92'f32, z: 0.95'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.FrameBgActive)] = ImVec4(x: 0.85'f32, y: 0.88'f32, z: 0.92'f32, w: 1.00'f32)

  # Title Bars & Menus
  style.colors[int(ImGuiCol.TitleBg)] = ImVec4(x: 0.92'f32, y: 0.92'f32, z: 0.90'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TitleBgActive)] = ImVec4(x: 0.88'f32, y: 0.88'f32, z: 0.86'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TitleBgCollapsed)] = ImVec4(x: 0.92'f32, y: 0.92'f32, z: 0.90'f32, w: 0.75'f32)
  style.colors[int(ImGuiCol.MenuBarBg)] = ImVec4(x: 0.92'f32, y: 0.92'f32, z: 0.90'f32, w: 1.00'f32)

  # Scrollbars
  style.colors[int(ImGuiCol.ScrollbarBg)] = ImVec4(x: 0.96'f32, y: 0.96'f32, z: 0.94'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.ScrollbarGrab)] = ImVec4(x: 0.80'f32, y: 0.80'f32, z: 0.78'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.ScrollbarGrabHovered)] = ImVec4(x: 0.70'f32, y: 0.70'f32, z: 0.68'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.ScrollbarGrabActive)] = ImVec4(x: 0.60'f32, y: 0.60'f32, z: 0.58'f32, w: 1.00'f32)

  # Interactables
  style.colors[int(ImGuiCol.CheckMark)] = ImVec4(x: 0.17'f32, y: 0.34'f32, z: 0.59'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.SliderGrab)] = ImVec4(x: 0.17'f32, y: 0.34'f32, z: 0.59'f32, w: 0.70'f32)
  style.colors[int(ImGuiCol.SliderGrabActive)] = ImVec4(x: 0.17'f32, y: 0.34'f32, z: 0.59'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.Button)] = ImVec4(x: 0.17'f32, y: 0.34'f32, z: 0.59'f32, w: 0.08'f32)
  style.colors[int(ImGuiCol.ButtonHovered)] = ImVec4(x: 0.17'f32, y: 0.34'f32, z: 0.59'f32, w: 0.20'f32)
  style.colors[int(ImGuiCol.ButtonActive)] = ImVec4(x: 0.17'f32, y: 0.34'f32, z: 0.59'f32, w: 0.35'f32)

  # Headers
  style.colors[int(ImGuiCol.Header)] = ImVec4(x: 0.17'f32, y: 0.34'f32, z: 0.59'f32, w: 0.12'f32)
  style.colors[int(ImGuiCol.HeaderHovered)] = ImVec4(x: 0.17'f32, y: 0.34'f32, z: 0.59'f32, w: 0.25'f32)
  style.colors[int(ImGuiCol.HeaderActive)] = ImVec4(x: 0.17'f32, y: 0.34'f32, z: 0.59'f32, w: 0.40'f32)

  # Tables
  style.colors[int(ImGuiCol.TableHeaderBg)] = ImVec4(x: 0.90'f32, y: 0.90'f32, z: 0.88'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TableBorderStrong)] = ImVec4(x: 0.75'f32, y: 0.75'f32, z: 0.72'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TableBorderLight)] = ImVec4(x: 0.85'f32, y: 0.85'f32, z: 0.82'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TableRowBg)] = ImVec4(x: 0.00'f32, y: 0.00'f32, z: 0.00'f32, w: 0.00'f32)
  style.colors[int(ImGuiCol.TableRowBgAlt)] = ImVec4(x: 0.00'f32, y: 0.00'f32, z: 0.00'f32, w: 0.03'f32)

  # Tabs
  style.colors[int(ImGuiCol.Tab)] = ImVec4(x: 0.92'f32, y: 0.92'f32, z: 0.90'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TabHovered)] = ImVec4(x: 0.17'f32, y: 0.34'f32, z: 0.59'f32, w: 0.20'f32)
  style.colors[int(ImGuiCol.TabActive)] = ImVec4(x: 0.17'f32, y: 0.34'f32, z: 0.59'f32, w: 0.20'f32)
  style.colors[int(ImGuiCol.TabUnfocused)] = ImVec4(x: 0.92'f32, y: 0.92'f32, z: 0.90'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TabUnfocusedActive)] = ImVec4(x: 0.96'f32, y: 0.96'f32, z: 0.94'f32, w: 1.00'f32)

  # Misc
  style.colors[int(ImGuiCol.PlotLines)] = ImVec4(x: 0.17'f32, y: 0.34'f32, z: 0.59'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.PlotLinesHovered)] = ImVec4(x: 0.17'f32, y: 0.34'f32, z: 0.59'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.PlotHistogram)] = ImVec4(x: 0.17'f32, y: 0.34'f32, z: 0.59'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.PlotHistogramHovered)] = ImVec4(x: 0.17'f32, y: 0.34'f32, z: 0.59'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TextSelectedBg)] = ImVec4(x: 0.17'f32, y: 0.34'f32, z: 0.59'f32, w: 0.25'f32)
  style.colors[int(ImGuiCol.DragDropTarget)] = ImVec4(x: 0.17'f32, y: 0.34'f32, z: 0.59'f32, w: 0.90'f32)
  style.colors[int(ImGuiCol.NavHighlight)] = ImVec4(x: 0.17'f32, y: 0.34'f32, z: 0.59'f32, w: 1.00'f32)

proc setupDosSetupStyle() = 
  let style = igGetStyle()

  # Properties
  style.windowRounding = 0.0f
  style.windowBorderSize = 1.0f
  style.childRounding = 0.0f
  style.childBorderSize = 1.0f
  style.popupRounding = 0.0f
  style.popupBorderSize = 1.0f
  style.frameRounding = 0.0f
  style.frameBorderSize = 1.0f
  style.scrollbarSize = 12.0f
  style.scrollbarRounding = 0.0f
  style.grabRounding = 0.0f
  style.tabRounding = 0.0f
  style.tabBorderSize = 1.0f

  # Text
  style.colors[int(ImGuiCol.Text)] = ImVec4(x: 1.00'f32, y: 1.00'f32, z: 1.00'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TextDisabled)] = ImVec4(x: 0.50'f32, y: 0.50'f32, z: 0.50'f32, w: 1.00'f32)

  # Backgrounds
  style.colors[int(ImGuiCol.WindowBg)] = ImVec4(x: 0.33'f32, y: 0.33'f32, z: 0.66'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.ChildBg)] = ImVec4(x: 0.33'f32, y: 0.33'f32, z: 0.66'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.PopupBg)] = ImVec4(x: 0.33'f32, y: 0.33'f32, z: 0.66'f32, w: 1.00'f32)

  # Borders & Separators
  style.colors[int(ImGuiCol.Border)] = ImVec4(x: 0.33'f32, y: 1.00'f32, z: 1.00'f32, w: 0.67'f32)
  style.colors[int(ImGuiCol.BorderShadow)] = ImVec4(x: 0.00'f32, y: 0.00'f32, z: 0.00'f32, w: 0.00'f32)
  style.colors[int(ImGuiCol.Separator)] = ImVec4(x: 0.33'f32, y: 1.00'f32, z: 1.00'f32, w: 0.67'f32)
  style.colors[int(ImGuiCol.SeparatorHovered)] = ImVec4(x: 1.00'f32, y: 1.00'f32, z: 1.00'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.SeparatorActive)] = ImVec4(x: 0.90'f32, y: 0.90'f32, z: 0.90'f32, w: 1.00'f32)

  # Frames
  style.colors[int(ImGuiCol.FrameBg)] = ImVec4(x: 0.02'f32, y: 0.08'f32, z: 0.25'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.FrameBgHovered)] = ImVec4(x: 0.66'f32, y: 0.66'f32, z: 0.66'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.FrameBgActive)] = ImVec4(x: 0.33'f32, y: 0.33'f32, z: 0.33'f32, w: 1.00'f32)

  # Title Bars & Menus
  style.colors[int(ImGuiCol.TitleBg)] = ImVec4(x: 0.02'f32, y: 0.08'f32, z: 0.25'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TitleBgActive)] = ImVec4(x: 0.00'f32, y: 0.00'f32, z: 0.66'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TitleBgCollapsed)] = ImVec4(x: 0.00'f32, y: 0.00'f32, z: 0.00'f32, w: 0.51'f32)
  style.colors[int(ImGuiCol.MenuBarBg)] = ImVec4(x: 0.14'f32, y: 0.14'f32, z: 0.14'f32, w: 1.00'f32)

  # Scrollbars
  style.colors[int(ImGuiCol.ScrollbarBg)] = ImVec4(x: 0.00'f32, y: 0.66'f32, z: 0.66'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.ScrollbarGrab)] = ImVec4(x: 0.33'f32, y: 1.00'f32, z: 1.00'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.ScrollbarGrabHovered)] = ImVec4(x: 1.00'f32, y: 1.00'f32, z: 1.00'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.ScrollbarGrabActive)] = ImVec4(x: 0.90'f32, y: 0.90'f32, z: 0.90'f32, w: 1.00'f32)

  # Interactables
  style.colors[int(ImGuiCol.CheckMark)] = ImVec4(x: 0.33'f32, y: 0.99'f32, z: 0.33'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.SliderGrab)] = ImVec4(x: 0.00'f32, y: 0.66'f32, z: 0.66'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.SliderGrabActive)] = ImVec4(x: 0.33'f32, y: 1.00'f32, z: 1.00'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.Button)] = ImVec4(x: 0.00'f32, y: 0.00'f32, z: 0.66'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.ButtonHovered)] = ImVec4(x: 0.66'f32, y: 0.66'f32, z: 0.66'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.ButtonActive)] = ImVec4(x: 0.33'f32, y: 0.33'f32, z: 0.33'f32, w: 1.00'f32)

  # Headers
  style.colors[int(ImGuiCol.Header)] = ImVec4(x: 0.00'f32, y: 0.00'f32, z: 0.66'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.HeaderHovered)] = ImVec4(x: 0.66'f32, y: 0.66'f32, z: 0.66'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.HeaderActive)] = ImVec4(x: 0.33'f32, y: 0.33'f32, z: 0.33'f32, w: 1.00'f32)

  # Tables
  style.colors[int(ImGuiCol.TableHeaderBg)] = ImVec4(x: 0.19'f32, y: 0.19'f32, z: 0.20'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TableBorderStrong)] = ImVec4(x: 0.31'f32, y: 0.31'f32, z: 0.35'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TableBorderLight)] = ImVec4(x: 0.23'f32, y: 0.23'f32, z: 0.25'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TableRowBg)] = ImVec4(x: 0.00'f32, y: 0.00'f32, z: 0.00'f32, w: 0.00'f32)
  style.colors[int(ImGuiCol.TableRowBgAlt)] = ImVec4(x: 1.00'f32, y: 1.00'f32, z: 1.00'f32, w: 0.06'f32)

  # Tabs
  style.colors[int(ImGuiCol.Tab)] = ImVec4(x: 0.02'f32, y: 0.08'f32, z: 0.25'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TabHovered)] = ImVec4(x: 0.66'f32, y: 0.66'f32, z: 0.66'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TabActive)] = ImVec4(x: 0.00'f32, y: 0.00'f32, z: 0.66'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TabUnfocused)] = ImVec4(x: 0.07'f32, y: 0.10'f32, z: 0.15'f32, w: 0.97'f32)
  style.colors[int(ImGuiCol.TabUnfocusedActive)] = ImVec4(x: 0.13'f32, y: 0.26'f32, z: 0.42'f32, w: 1.00'f32)

  # Misc
  style.colors[int(ImGuiCol.PlotLines)] = ImVec4(x: 0.61'f32, y: 0.61'f32, z: 0.61'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.PlotLinesHovered)] = ImVec4(x: 1.00'f32, y: 0.43'f32, z: 0.35'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.PlotHistogram)] = ImVec4(x: 0.90'f32, y: 0.70'f32, z: 0.00'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.PlotHistogramHovered)] = ImVec4(x: 1.00'f32, y: 0.60'f32, z: 0.00'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.TextSelectedBg)] = ImVec4(x: 0.26'f32, y: 0.59'f32, z: 0.98'f32, w: 0.35'f32)
  style.colors[int(ImGuiCol.DragDropTarget)] = ImVec4(x: 1.00'f32, y: 1.00'f32, z: 0.00'f32, w: 0.90'f32)
  style.colors[int(ImGuiCol.NavHighlight)] = ImVec4(x: 0.26'f32, y: 0.59'f32, z: 0.98'f32, w: 1.00'f32)
  style.colors[int(ImGuiCol.ModalWindowDimBg)] = ImVec4(x: 0.00'f32, y: 0.00'f32, z: 0.00'f32, w: 0.50'f32)

proc setSelectedStyle*(indx: int = 0) =
  setupStyleGeometry()
  case indx
  of 0:
    setupImGuiDarkStyle()
  of 1:
    setupImGuiLightStyle()
  of 2:
    setupImGuiClassicStyle()
  of 3:
    setupForestGreenStyle()
  of 4:
    setupSapphireStyle()
  of 5:
    setupAmethystStyle()
  of 6:
    setupAmberYellowStyle()
  of 7:
    setupCrimsonVesuviusStyle()
  of 8:
    setupRoseQuartzStyle()
  of 9:
    setupCyberpunkStyle()
  of 10:
    setupPaperAndInkStyle()
  of 11:
    setupDosSetupStyle()
  else:
    discard

  makeResizeGripInvisible()
  #echo "Style is changed to " & $availStyles[indx]


