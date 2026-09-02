import nimgl/imgui
import std/sequtils


var availStyles = @["ImGui Dark", "ImGui Light", "ImGui Classic", "Forest Green", "Sapphire", "Amethyst", "Amber Yellow", "Crimson Vesuvius", "Rose Quartz", "Cyberpunk", "SETUP.EXE"]

var availStylesCSTRING*: seq[cstring] = availStyles.mapIt(it.cstring)

const ImVec4 = proc(x: float32, y: float32, z: float32, w: float32): ImVec4 = ImVec4(x: x, y: y, z: z, w: w)

proc setupImGuiDarkStyle*() =
  igStyleColorsDark()

proc setupImGuiLightStyle*() =
  igStyleColorsLight()

proc setupImGuiClassicStyle*() =
  igStyleColorsClassic()

#---------------------------------------------------------------------------------------

proc setupForestGreenStyle*() =
  let style = igGetStyle()

  style.colors[ImGuiCol.Text.int32]                 = ImVec4(0.85f, 0.90f, 0.85f, 1.00f)
  style.colors[ImGuiCol.TextDisabled.int32]         = ImVec4(0.50f, 0.55f, 0.50f, 1.00f)
  style.colors[ImGuiCol.WindowBg.int32]             = ImVec4(0.08f, 0.11f, 0.08f, 1.00f)
  style.colors[ImGuiCol.ChildBg.int32]              = ImVec4(0.08f, 0.11f, 0.08f, 1.00f)
  style.colors[ImGuiCol.PopupBg.int32]              = ImVec4(0.08f, 0.11f, 0.08f, 1.00f)
  style.colors[ImGuiCol.Border.int32]               = ImVec4(0.18f, 0.28f, 0.18f, 0.80f)
  style.colors[ImGuiCol.BorderShadow.int32]         = ImVec4(0.00f, 0.00f, 0.00f, 0.00f)
  style.colors[ImGuiCol.FrameBg.int32]              = ImVec4(0.12f, 0.18f, 0.12f, 1.00f)
  style.colors[ImGuiCol.FrameBgHovered.int32]       = ImVec4(0.18f, 0.30f, 0.18f, 1.00f)
  style.colors[ImGuiCol.FrameBgActive.int32]        = ImVec4(0.24f, 0.42f, 0.24f, 1.00f)
  style.colors[ImGuiCol.TitleBg.int32]              = ImVec4(0.09f, 0.14f, 0.09f, 1.00f)
  style.colors[ImGuiCol.TitleBgActive.int32]        = ImVec4(0.14f, 0.26f, 0.14f, 1.00f)
  style.colors[ImGuiCol.TitleBgCollapsed.int32]     = ImVec4(0.05f, 0.08f, 0.05f, 1.00f)
  style.colors[ImGuiCol.MenuBarBg.int32]            = ImVec4(0.09f, 0.14f, 0.09f, 1.00f)
  style.colors[ImGuiCol.ScrollbarBg.int32]          = ImVec4(0.08f, 0.11f, 0.08f, 1.00f)
  style.colors[ImGuiCol.ScrollbarGrab.int32]        = ImVec4(0.18f, 0.28f, 0.18f, 1.00f)
  style.colors[ImGuiCol.ScrollbarGrabHovered.int32] = ImVec4(0.25f, 0.38f, 0.25f, 1.00f)
  style.colors[ImGuiCol.ScrollbarGrabActive.int32]  = ImVec4(0.32f, 0.48f, 0.32f, 1.00f)
  style.colors[ImGuiCol.CheckMark.int32]            = ImVec4(0.45f, 0.75f, 0.45f, 1.00f)
  style.colors[ImGuiCol.SliderGrab.int32]           = ImVec4(0.35f, 0.55f, 0.35f, 1.00f)
  style.colors[ImGuiCol.SliderGrabActive.int32]     = ImVec4(0.45f, 0.70f, 0.45f, 1.00f)
  style.colors[ImGuiCol.Button.int32]               = ImVec4(0.18f, 0.35f, 0.18f, 1.00f)
  style.colors[ImGuiCol.ButtonHovered.int32]        = ImVec4(0.25f, 0.45f, 0.25f, 1.00f)
  style.colors[ImGuiCol.ButtonActive.int32]         = ImVec4(0.32f, 0.55f, 0.32f, 1.00f)
  style.colors[ImGuiCol.Header.int32]               = ImVec4(0.18f, 0.35f, 0.18f, 1.00f)
  style.colors[ImGuiCol.HeaderHovered.int32]        = ImVec4(0.25f, 0.45f, 0.25f, 1.00f)
  style.colors[ImGuiCol.HeaderActive.int32]         = ImVec4(0.32f, 0.55f, 0.32f, 1.00f)
  style.colors[ImGuiCol.Separator.int32]            = ImVec4(0.18f, 0.28f, 0.18f, 1.00f)
  style.colors[ImGuiCol.SeparatorHovered.int32]     = ImVec4(0.25f, 0.45f, 0.25f, 1.00f)
  style.colors[ImGuiCol.SeparatorActive.int32]      = ImVec4(0.32f, 0.55f, 0.32f, 1.00f)
  style.colors[ImGuiCol.Tab.int32]                  = ImVec4(0.12f, 0.22f, 0.12f, 1.00f)
  style.colors[ImGuiCol.TabHovered.int32]           = ImVec4(0.25f, 0.45f, 0.25f, 1.00f)
  style.colors[ImGuiCol.TabActive.int32]            = ImVec4(0.20f, 0.38f, 0.20f, 1.00f)
  style.colors[ImGuiCol.TabUnfocused.int32]         = ImVec4(0.08f, 0.15f, 0.08f, 1.00f)
  style.colors[ImGuiCol.TabUnfocusedActive.int32]   = ImVec4(0.12f, 0.22f, 0.12f, 1.00f)
  style.colors[ImGuiCol.PlotLines.int32]            = ImVec4(0.40f, 0.70f, 0.40f, 1.00f)
  style.colors[ImGuiCol.PlotLinesHovered.int32]     = ImVec4(0.50f, 0.85f, 0.50f, 1.00f)
  style.colors[ImGuiCol.PlotHistogram.int32]        = ImVec4(0.40f, 0.70f, 0.40f, 1.00f)
  style.colors[ImGuiCol.PlotHistogramHovered.int32] = ImVec4(0.50f, 0.85f, 0.50f, 1.00f)
  style.colors[ImGuiCol.TableHeaderBg.int32]        = ImVec4(0.12f, 0.22f, 0.12f, 1.00f)
  style.colors[ImGuiCol.TableBorderStrong.int32]    = ImVec4(0.20f, 0.35f, 0.20f, 1.00f)
  style.colors[ImGuiCol.TableBorderLight.int32]     = ImVec4(0.15f, 0.25f, 0.15f, 1.00f)
  style.colors[ImGuiCol.TableRowBg.int32]           = ImVec4(0.00f, 0.00f, 0.00f, 0.00f)
  style.colors[ImGuiCol.TableRowBgAlt.int32]        = ImVec4(0.08f, 0.14f, 0.08f, 0.50f)
  style.colors[ImGuiCol.TextSelectedBg.int32]       = ImVec4(0.25f, 0.55f, 0.25f, 0.50f)
  style.colors[ImGuiCol.DragDropTarget.int32]       = ImVec4(0.60f, 0.90f, 0.60f, 1.00f)
  style.colors[ImGuiCol.NavHighlight.int32]         = ImVec4(0.40f, 0.80f, 0.40f, 1.00f)
  style.colors[ImGuiCol.NavWindowingDimBg.int32]    = ImVec4(0.10f, 0.15f, 0.10f, 0.50f)
  style.colors[ImGuiCol.ModalWindowDimBg.int32]     = ImVec4(0.05f, 0.08f, 0.05f, 0.60f)

#---------------------------------------------------------------------------------------

proc setupSapphireStyle*() =
  let style = igGetStyle()

  style.colors[ImGuiCol.Text.int32]                 = ImVec4(0.90f, 0.93f, 0.97f, 1.00f)
  style.colors[ImGuiCol.TextDisabled.int32]         = ImVec4(0.40f, 0.50f, 0.65f, 1.00f)
  style.colors[ImGuiCol.WindowBg.int32]             = ImVec4(0.09f, 0.12f, 0.16f, 1.00f)
  style.colors[ImGuiCol.ChildBg.int32]              = ImVec4(0.09f, 0.12f, 0.16f, 1.00f)
  style.colors[ImGuiCol.PopupBg.int32]              = ImVec4(0.09f, 0.12f, 0.16f, 1.00f)
  style.colors[ImGuiCol.Border.int32]               = ImVec4(0.15f, 0.25f, 0.35f, 0.70f)
  style.colors[ImGuiCol.BorderShadow.int32]         = ImVec4(0.00f, 0.00f, 0.00f, 0.00f)
  style.colors[ImGuiCol.FrameBg.int32]              = ImVec4(0.12f, 0.18f, 0.26f, 1.00f)
  style.colors[ImGuiCol.FrameBgHovered.int32]       = ImVec4(0.18f, 0.28f, 0.40f, 1.00f)
  style.colors[ImGuiCol.FrameBgActive.int32]        = ImVec4(0.25f, 0.38f, 0.55f, 1.00f)
  style.colors[ImGuiCol.TitleBg.int32]              = ImVec4(0.09f, 0.12f, 0.18f, 1.00f)
  style.colors[ImGuiCol.TitleBgActive.int32]        = ImVec4(0.14f, 0.22f, 0.35f, 1.00f)
  style.colors[ImGuiCol.TitleBgCollapsed.int32]     = ImVec4(0.05f, 0.08f, 0.12f, 1.00f)
  style.colors[ImGuiCol.MenuBarBg.int32]            = ImVec4(0.12f, 0.16f, 0.22f, 1.00f)
  style.colors[ImGuiCol.ScrollbarBg.int32]          = ImVec4(0.09f, 0.12f, 0.16f, 1.00f)
  style.colors[ImGuiCol.ScrollbarGrab.int32]        = ImVec4(0.20f, 0.32f, 0.48f, 1.00f)
  style.colors[ImGuiCol.ScrollbarGrabHovered.int32] = ImVec4(0.28f, 0.42f, 0.60f, 1.00f)
  style.colors[ImGuiCol.ScrollbarGrabActive.int32]  = ImVec4(0.35f, 0.50f, 0.75f, 1.00f)
  style.colors[ImGuiCol.CheckMark.int32]            = ImVec4(0.40f, 0.70f, 1.00f, 1.00f)
  style.colors[ImGuiCol.SliderGrab.int32]           = ImVec4(0.30f, 0.55f, 0.85f, 1.00f)
  style.colors[ImGuiCol.SliderGrabActive.int32]     = ImVec4(0.45f, 0.75f, 1.00f, 1.00f)
  style.colors[ImGuiCol.Button.int32]               = ImVec4(0.18f, 0.35f, 0.55f, 1.00f)
  style.colors[ImGuiCol.ButtonHovered.int32]        = ImVec4(0.25f, 0.48f, 0.75f, 1.00f)
  style.colors[ImGuiCol.ButtonActive.int32]         = ImVec4(0.35f, 0.60f, 0.90f, 1.00f)
  style.colors[ImGuiCol.Header.int32]               = ImVec4(0.18f, 0.35f, 0.55f, 1.00f)
  style.colors[ImGuiCol.HeaderHovered.int32]        = ImVec4(0.25f, 0.48f, 0.75f, 1.00f)
  style.colors[ImGuiCol.HeaderActive.int32]         = ImVec4(0.35f, 0.60f, 0.90f, 1.00f)
  style.colors[ImGuiCol.Tab.int32]                  = ImVec4(0.12f, 0.20f, 0.32f, 1.00f)
  style.colors[ImGuiCol.TabHovered.int32]           = ImVec4(0.25f, 0.45f, 0.70f, 1.00f)
  style.colors[ImGuiCol.TabActive.int32]            = ImVec4(0.18f, 0.35f, 0.55f, 1.00f)
  style.colors[ImGuiCol.TabUnfocused.int32]         = ImVec4(0.08f, 0.12f, 0.18f, 1.00f)
  style.colors[ImGuiCol.TabUnfocusedActive.int32]   = ImVec4(0.12f, 0.20f, 0.32f, 1.00f)
  style.colors[ImGuiCol.TableHeaderBg.int32]        = ImVec4(0.15f, 0.25f, 0.40f, 1.00f)
  style.colors[ImGuiCol.TableBorderStrong.int32]    = ImVec4(0.20f, 0.35f, 0.55f, 1.00f)
  style.colors[ImGuiCol.TableBorderLight.int32]     = ImVec4(0.15f, 0.25f, 0.40f, 1.00f)
  style.colors[ImGuiCol.TableRowBg.int32]           = ImVec4(0.00f, 0.00f, 0.00f, 0.00f)
  style.colors[ImGuiCol.TableRowBgAlt.int32]        = ImVec4(1.00f, 1.00f, 1.00f, 0.05f)
  style.colors[ImGuiCol.TextSelectedBg.int32]       = ImVec4(0.30f, 0.55f, 0.85f, 0.40f)
  style.colors[ImGuiCol.DragDropTarget.int32]       = ImVec4(0.50f, 0.80f, 1.00f, 0.90f)
  style.colors[ImGuiCol.NavHighlight.int32]         = ImVec4(0.40f, 0.70f, 1.00f, 1.00f)
  style.colors[ImGuiCol.Separator.int32]            = ImVec4(0.15f, 0.25f, 0.35f, 0.70f)
  style.colors[ImGuiCol.SeparatorHovered.int32]     = ImVec4(0.25f, 0.48f, 0.75f, 1.00f)
  style.colors[ImGuiCol.SeparatorActive.int32]      = ImVec4(0.35f, 0.60f, 0.90f, 1.00f)

#---------------------------------------------------------------------------------------

proc setupAmethystStyle*() =
  let style = igGetStyle()

  style.colors[ImGuiCol.Text.int32]                 = ImVec4(0.92f, 0.90f, 0.95f, 1.00f)
  style.colors[ImGuiCol.TextDisabled.int32]         = ImVec4(0.55f, 0.50f, 0.60f, 1.00f)
  style.colors[ImGuiCol.WindowBg.int32]             = ImVec4(0.11f, 0.09f, 0.14f, 1.00f)
  style.colors[ImGuiCol.ChildBg.int32]              = ImVec4(0.11f, 0.09f, 0.14f, 1.00f)
  style.colors[ImGuiCol.PopupBg.int32]              = ImVec4(0.11f, 0.09f, 0.14f, 1.00f)
  style.colors[ImGuiCol.Border.int32]               = ImVec4(0.25f, 0.20f, 0.35f, 0.80f)
  style.colors[ImGuiCol.BorderShadow.int32]         = ImVec4(0.00f, 0.00f, 0.00f, 0.00f)
  style.colors[ImGuiCol.FrameBg.int32]              = ImVec4(0.15f, 0.12f, 0.22f, 1.00f)
  style.colors[ImGuiCol.FrameBgHovered.int32]       = ImVec4(0.25f, 0.20f, 0.38f, 1.00f)
  style.colors[ImGuiCol.FrameBgActive.int32]        = ImVec4(0.35f, 0.25f, 0.55f, 1.00f)
  style.colors[ImGuiCol.TitleBg.int32]              = ImVec4(0.12f, 0.09f, 0.18f, 1.00f)
  style.colors[ImGuiCol.TitleBgActive.int32]        = ImVec4(0.20f, 0.14f, 0.32f, 1.00f)
  style.colors[ImGuiCol.TitleBgCollapsed.int32]     = ImVec4(0.07f, 0.05f, 0.10f, 1.00f)
  style.colors[ImGuiCol.MenuBarBg.int32]            = ImVec4(0.12f, 0.09f, 0.18f, 1.00f)
  style.colors[ImGuiCol.ScrollbarBg.int32]          = ImVec4(0.11f, 0.09f, 0.14f, 1.00f)
  style.colors[ImGuiCol.ScrollbarGrab.int32]        = ImVec4(0.25f, 0.20f, 0.35f, 1.00f)
  style.colors[ImGuiCol.ScrollbarGrabHovered.int32] = ImVec4(0.35f, 0.30f, 0.50f, 1.00f)
  style.colors[ImGuiCol.ScrollbarGrabActive.int32]  = ImVec4(0.45f, 0.40f, 0.65f, 1.00f)
  style.colors[ImGuiCol.CheckMark.int32]            = ImVec4(0.65f, 0.45f, 0.95f, 1.00f)
  style.colors[ImGuiCol.SliderGrab.int32]           = ImVec4(0.50f, 0.35f, 0.75f, 1.00f)
  style.colors[ImGuiCol.SliderGrabActive.int32]     = ImVec4(0.65f, 0.45f, 0.95f, 1.00f)
  style.colors[ImGuiCol.Button.int32]               = ImVec4(0.25f, 0.20f, 0.40f, 1.00f)
  style.colors[ImGuiCol.ButtonHovered.int32]        = ImVec4(0.38f, 0.28f, 0.62f, 1.00f)
  style.colors[ImGuiCol.ButtonActive.int32]         = ImVec4(0.50f, 0.35f, 0.80f, 1.00f)
  style.colors[ImGuiCol.Header.int32]               = ImVec4(0.25f, 0.20f, 0.40f, 1.00f)
  style.colors[ImGuiCol.HeaderHovered.int32]        = ImVec4(0.38f, 0.28f, 0.62f, 1.00f)
  style.colors[ImGuiCol.HeaderActive.int32]         = ImVec4(0.50f, 0.35f, 0.80f, 1.00f)
  style.colors[ImGuiCol.Tab.int32]                  = ImVec4(0.15f, 0.12f, 0.25f, 1.00f)
  style.colors[ImGuiCol.TabHovered.int32]           = ImVec4(0.38f, 0.28f, 0.62f, 1.00f)
  style.colors[ImGuiCol.TabActive.int32]            = ImVec4(0.28f, 0.20f, 0.45f, 1.00f)
  style.colors[ImGuiCol.TabUnfocused.int32]         = ImVec4(0.10f, 0.08f, 0.15f, 1.00f)
  style.colors[ImGuiCol.TabUnfocusedActive.int32]   = ImVec4(0.15f, 0.12f, 0.25f, 1.00f)
  style.colors[ImGuiCol.TableHeaderBg.int32]        = ImVec4(0.18f, 0.15f, 0.28f, 1.00f)
  style.colors[ImGuiCol.TableBorderStrong.int32]    = ImVec4(0.25f, 0.20f, 0.40f, 1.00f)
  style.colors[ImGuiCol.TableBorderLight.int32]     = ImVec4(0.20f, 0.15f, 0.30f, 1.00f)
  style.colors[ImGuiCol.TableRowBg.int32]           = ImVec4(0.00f, 0.00f, 0.00f, 0.00f)
  style.colors[ImGuiCol.TableRowBgAlt.int32]        = ImVec4(1.00f, 1.00f, 1.00f, 0.04f)
  style.colors[ImGuiCol.TextSelectedBg.int32]       = ImVec4(0.50f, 0.35f, 0.80f, 0.35f)
  style.colors[ImGuiCol.DragDropTarget.int32]       = ImVec4(0.80f, 0.65f, 1.00f, 0.95f)
  style.colors[ImGuiCol.NavHighlight.int32]         = ImVec4(0.60f, 0.45f, 0.90f, 1.00f)
  style.colors[ImGuiCol.Separator.int32]            = ImVec4(0.25f, 0.20f, 0.35f, 1.00f)
  style.colors[ImGuiCol.SeparatorHovered.int32]     = ImVec4(0.38f, 0.28f, 0.62f, 1.00f)
  style.colors[ImGuiCol.SeparatorActive.int32]      = ImVec4(0.50f, 0.35f, 0.80f, 1.00f)

#---------------------------------------------------------------------------------------

proc setupAmberYellowStyle*() =
  let style = igGetStyle()

  style.colors[ImGuiCol.Text.int32]                 = ImVec4(1.00f, 0.95f, 0.80f, 1.00f)
  style.colors[ImGuiCol.TextDisabled.int32]         = ImVec4(0.50f, 0.45f, 0.30f, 1.00f)
  style.colors[ImGuiCol.WindowBg.int32]             = ImVec4(0.09f, 0.09f, 0.08f, 1.00f)
  style.colors[ImGuiCol.ChildBg.int32]              = ImVec4(0.09f, 0.09f, 0.08f, 1.00f)
  style.colors[ImGuiCol.PopupBg.int32]              = ImVec4(0.09f, 0.09f, 0.08f, 1.00f)
  style.colors[ImGuiCol.Border.int32]               = ImVec4(0.30f, 0.25f, 0.10f, 0.80f)
  style.colors[ImGuiCol.BorderShadow.int32]         = ImVec4(0.00f, 0.00f, 0.00f, 0.00f)
  style.colors[ImGuiCol.FrameBg.int32]              = ImVec4(0.15f, 0.14f, 0.10f, 1.00f)
  style.colors[ImGuiCol.FrameBgHovered.int32]       = ImVec4(0.25f, 0.22f, 0.12f, 1.00f)
  style.colors[ImGuiCol.FrameBgActive.int32]        = ImVec4(0.35f, 0.30f, 0.15f, 1.00f)
  style.colors[ImGuiCol.TitleBg.int32]              = ImVec4(0.12f, 0.11f, 0.08f, 1.00f)
  style.colors[ImGuiCol.TitleBgActive.int32]        = ImVec4(0.20f, 0.18f, 0.10f, 1.00f)
  style.colors[ImGuiCol.TitleBgCollapsed.int32]     = ImVec4(0.05f, 0.05f, 0.04f, 1.00f)
  style.colors[ImGuiCol.MenuBarBg.int32]            = ImVec4(0.12f, 0.11f, 0.08f, 1.00f)
  style.colors[ImGuiCol.ScrollbarBg.int32]          = ImVec4(0.09f, 0.09f, 0.08f, 1.00f)
  style.colors[ImGuiCol.ScrollbarGrab.int32]        = ImVec4(0.35f, 0.30f, 0.10f, 1.00f)
  style.colors[ImGuiCol.ScrollbarGrabHovered.int32] = ImVec4(0.45f, 0.40f, 0.15f, 1.00f)
  style.colors[ImGuiCol.ScrollbarGrabActive.int32]  = ImVec4(0.55f, 0.50f, 0.20f, 1.00f)
  style.colors[ImGuiCol.CheckMark.int32]            = ImVec4(0.95f, 0.80f, 0.10f, 1.00f)
  style.colors[ImGuiCol.SliderGrab.int32]           = ImVec4(0.70f, 0.60f, 0.10f, 1.00f)
  style.colors[ImGuiCol.SliderGrabActive.int32]     = ImVec4(0.95f, 0.80f, 0.10f, 1.00f)
  style.colors[ImGuiCol.Button.int32]               = ImVec4(0.30f, 0.25f, 0.05f, 1.00f)
  style.colors[ImGuiCol.ButtonHovered.int32]        = ImVec4(0.45f, 0.38f, 0.10f, 1.00f)
  style.colors[ImGuiCol.ButtonActive.int32]         = ImVec4(0.60f, 0.50f, 0.15f, 1.00f)
  style.colors[ImGuiCol.Header.int32]               = ImVec4(0.30f, 0.25f, 0.05f, 1.00f)
  style.colors[ImGuiCol.HeaderHovered.int32]        = ImVec4(0.45f, 0.38f, 0.10f, 1.00f)
  style.colors[ImGuiCol.HeaderActive.int32]         = ImVec4(0.60f, 0.50f, 0.15f, 1.00f)
  style.colors[ImGuiCol.Tab.int32]                  = ImVec4(0.15f, 0.14f, 0.10f, 1.00f)
  style.colors[ImGuiCol.TabHovered.int32]           = ImVec4(0.45f, 0.38f, 0.10f, 1.00f)
  style.colors[ImGuiCol.TabActive.int32]            = ImVec4(0.35f, 0.30f, 0.10f, 1.00f)
  style.colors[ImGuiCol.TabUnfocused.int32]         = ImVec4(0.08f, 0.08f, 0.07f, 1.00f)
  style.colors[ImGuiCol.TabUnfocusedActive.int32]   = ImVec4(0.15f, 0.14f, 0.10f, 1.00f)
  style.colors[ImGuiCol.TableHeaderBg.int32]        = ImVec4(0.18f, 0.16f, 0.10f, 1.00f)
  style.colors[ImGuiCol.TableBorderStrong.int32]    = ImVec4(0.35f, 0.30f, 0.15f, 1.00f)
  style.colors[ImGuiCol.TableBorderLight.int32]     = ImVec4(0.25f, 0.20f, 0.10f, 1.00f)
  style.colors[ImGuiCol.TableRowBg.int32]           = ImVec4(0.00f, 0.00f, 0.00f, 0.00f)
  style.colors[ImGuiCol.TableRowBgAlt.int32]        = ImVec4(1.00f, 1.00f, 1.00f, 0.03f)
  style.colors[ImGuiCol.TextSelectedBg.int32]       = ImVec4(0.95f, 0.80f, 0.10f, 0.25f)
  style.colors[ImGuiCol.DragDropTarget.int32]       = ImVec4(1.00f, 0.85f, 0.00f, 0.90f)
  style.colors[ImGuiCol.NavHighlight.int32]         = ImVec4(0.95f, 0.80f, 0.10f, 1.00f)
  style.colors[ImGuiCol.Separator.int32]            = ImVec4(0.30f, 0.25f, 0.10f, 0.80f)
  style.colors[ImGuiCol.SeparatorHovered.int32]     = ImVec4(0.45f, 0.38f, 0.10f, 1.00f)
  style.colors[ImGuiCol.SeparatorActive.int32]      = ImVec4(0.60f, 0.50f, 0.15f, 1.00f)

#---------------------------------------------------------------------------------------

proc setupCrimsonVesuviusStyle*() =
  let style = igGetStyle()

  style.colors[ImGuiCol.Text.int32]                 = ImVec4(1.00f, 0.90f, 0.90f, 1.00f)
  style.colors[ImGuiCol.TextDisabled.int32]         = ImVec4(0.50f, 0.40f, 0.40f, 1.00f)
  style.colors[ImGuiCol.WindowBg.int32]             = ImVec4(0.10f, 0.09f, 0.09f, 1.00f)
  style.colors[ImGuiCol.ChildBg.int32]              = ImVec4(0.10f, 0.09f, 0.09f, 1.00f)
  style.colors[ImGuiCol.PopupBg.int32]              = ImVec4(0.10f, 0.09f, 0.09f, 1.00f)
  style.colors[ImGuiCol.Border.int32]               = ImVec4(0.25f, 0.15f, 0.15f, 0.80f)
  style.colors[ImGuiCol.BorderShadow.int32]         = ImVec4(0.00f, 0.00f, 0.00f, 0.00f)
  style.colors[ImGuiCol.FrameBg.int32]              = ImVec4(0.15f, 0.10f, 0.10f, 1.00f)
  style.colors[ImGuiCol.FrameBgHovered.int32]       = ImVec4(0.25f, 0.15f, 0.15f, 1.00f)
  style.colors[ImGuiCol.FrameBgActive.int32]        = ImVec4(0.35f, 0.20f, 0.20f, 1.00f)
  style.colors[ImGuiCol.TitleBg.int32]              = ImVec4(0.12f, 0.08f, 0.08f, 1.00f)
  style.colors[ImGuiCol.TitleBgActive.int32]        = ImVec4(0.25f, 0.10f, 0.10f, 1.00f)
  style.colors[ImGuiCol.TitleBgCollapsed.int32]     = ImVec4(0.05f, 0.05f, 0.05f, 1.00f)
  style.colors[ImGuiCol.MenuBarBg.int32]            = ImVec4(0.12f, 0.08f, 0.08f, 1.00f)
  style.colors[ImGuiCol.ScrollbarBg.int32]          = ImVec4(0.10f, 0.09f, 0.09f, 1.00f)
  style.colors[ImGuiCol.ScrollbarGrab.int32]        = ImVec4(0.25f, 0.12f, 0.12f, 1.00f)
  style.colors[ImGuiCol.ScrollbarGrabHovered.int32] = ImVec4(0.35f, 0.15f, 0.15f, 1.00f)
  style.colors[ImGuiCol.ScrollbarGrabActive.int32]  = ImVec4(0.45f, 0.20f, 0.20f, 1.00f)
  style.colors[ImGuiCol.CheckMark.int32]            = ImVec4(0.85f, 0.15f, 0.15f, 1.00f)
  style.colors[ImGuiCol.SliderGrab.int32]           = ImVec4(0.60f, 0.12f, 0.12f, 1.00f)
  style.colors[ImGuiCol.SliderGrabActive.int32]     = ImVec4(0.85f, 0.15f, 0.15f, 1.00f)
  style.colors[ImGuiCol.Button.int32]               = ImVec4(0.30f, 0.12f, 0.12f, 1.00f)
  style.colors[ImGuiCol.ButtonHovered.int32]        = ImVec4(0.50f, 0.18f, 0.18f, 1.00f)
  style.colors[ImGuiCol.ButtonActive.int32]         = ImVec4(0.70f, 0.25f, 0.25f, 1.00f)
  style.colors[ImGuiCol.Header.int32]               = ImVec4(0.30f, 0.12f, 0.12f, 1.00f)
  style.colors[ImGuiCol.HeaderHovered.int32]        = ImVec4(0.50f, 0.18f, 0.18f, 1.00f)
  style.colors[ImGuiCol.HeaderActive.int32]         = ImVec4(0.70f, 0.25f, 0.25f, 1.00f)
  style.colors[ImGuiCol.Tab.int32]                  = ImVec4(0.15f, 0.10f, 0.10f, 1.00f)
  style.colors[ImGuiCol.TabHovered.int32]           = ImVec4(0.50f, 0.18f, 0.18f, 1.00f)
  style.colors[ImGuiCol.TabActive.int32]            = ImVec4(0.35f, 0.12f, 0.12f, 1.00f)
  style.colors[ImGuiCol.TabUnfocused.int32]         = ImVec4(0.10f, 0.08f, 0.08f, 1.00f)
  style.colors[ImGuiCol.TabUnfocusedActive.int32]   = ImVec4(0.15f, 0.10f, 0.10f, 1.00f)
  style.colors[ImGuiCol.Separator.int32]            = ImVec4(0.25f, 0.15f, 0.15f, 1.00f)
  style.colors[ImGuiCol.SeparatorHovered.int32]     = ImVec4(0.50f, 0.18f, 0.18f, 1.00f)
  style.colors[ImGuiCol.SeparatorActive.int32]      = ImVec4(0.70f, 0.25f, 0.25f, 1.00f)
  style.colors[ImGuiCol.TableHeaderBg.int32]        = ImVec4(0.15f, 0.10f, 0.10f, 1.00f)
  style.colors[ImGuiCol.TableBorderStrong.int32]    = ImVec4(0.25f, 0.15f, 0.15f, 1.00f)
  style.colors[ImGuiCol.TableBorderLight.int32]     = ImVec4(0.20f, 0.12f, 0.12f, 1.00f)
  style.colors[ImGuiCol.TableRowBg.int32]           = ImVec4(0.00f, 0.00f, 0.00f, 0.00f)
  style.colors[ImGuiCol.TableRowBgAlt.int32]        = ImVec4(1.00f, 1.00f, 1.00f, 0.04f)
  style.colors[ImGuiCol.PlotLines.int32]            = ImVec4(0.85f, 0.20f, 0.20f, 1.00f)
  style.colors[ImGuiCol.PlotLinesHovered.int32]     = ImVec4(1.00f, 0.30f, 0.30f, 1.00f)
  style.colors[ImGuiCol.PlotHistogram.int32]        = ImVec4(0.85f, 0.20f, 0.20f, 1.00f)
  style.colors[ImGuiCol.PlotHistogramHovered.int32] = ImVec4(1.00f, 0.30f, 0.30f, 1.00f)
  style.colors[ImGuiCol.TextSelectedBg.int32]       = ImVec4(0.85f, 0.15f, 0.15f, 0.35f)
  style.colors[ImGuiCol.NavHighlight.int32]         = ImVec4(0.85f, 0.15f, 0.15f, 1.00f)

#---------------------------------------------------------------------------------------

proc setupRoseQuartzStyle*() =
  let style = igGetStyle()

  style.colors[int(ImGuiCol.Text)]                  = ImVec4(0.95f, 0.90f, 0.95f, 1.00f)
  style.colors[int(ImGuiCol.TextDisabled)]          = ImVec4(0.55f, 0.45f, 0.55f, 1.00f)
  style.colors[ImGuiCol.WindowBg.int32]             = ImVec4(0.14f, 0.12f, 0.14f, 1.00f)
  style.colors[ImGuiCol.ChildBg.int32]              = ImVec4(0.14f, 0.12f, 0.14f, 1.00f)
  style.colors[ImGuiCol.PopupBg.int32]              = ImVec4(0.14f, 0.12f, 0.14f, 1.00f)
  style.colors[ImGuiCol.Border.int32]               = ImVec4(0.35f, 0.25f, 0.35f, 0.50f)
  style.colors[ImGuiCol.BorderShadow.int32]         = ImVec4(0.00f, 0.00f, 0.00f, 0.00f)
  style.colors[ImGuiCol.FrameBg.int32]              = ImVec4(0.20f, 0.15f, 0.20f, 1.00f)
  style.colors[ImGuiCol.FrameBgHovered.int32]       = ImVec4(0.30f, 0.22f, 0.30f, 1.00f)
  style.colors[ImGuiCol.FrameBgActive.int32]        = ImVec4(0.40f, 0.28f, 0.40f, 1.00f)
  style.colors[ImGuiCol.TitleBg.int32]              = ImVec4(0.15f, 0.10f, 0.15f, 1.00f)
  style.colors[ImGuiCol.TitleBgActive.int32]        = ImVec4(0.25f, 0.15f, 0.25f, 1.00f)
  style.colors[ImGuiCol.TitleBgCollapsed.int32]     = ImVec4(0.08f, 0.06f, 0.08f, 1.00f)
  style.colors[ImGuiCol.MenuBarBg.int32]            = ImVec4(0.15f, 0.10f, 0.15f, 1.00f)
  style.colors[ImGuiCol.ScrollbarBg.int32]          = ImVec4(0.14f, 0.12f, 0.14f, 1.00f)
  style.colors[ImGuiCol.ScrollbarGrab.int32]        = ImVec4(0.40f, 0.25f, 0.40f, 1.00f)
  style.colors[ImGuiCol.ScrollbarGrabHovered.int32] = ImVec4(0.55f, 0.35f, 0.55f, 1.00f)
  style.colors[ImGuiCol.ScrollbarGrabActive.int32]  = ImVec4(0.70f, 0.45f, 0.70f, 1.00f)
  style.colors[ImGuiCol.CheckMark.int32]            = ImVec4(0.95f, 0.60f, 0.75f, 1.00f)
  style.colors[ImGuiCol.SliderGrab.int32]           = ImVec4(0.85f, 0.50f, 0.65f, 1.00f)
  style.colors[ImGuiCol.SliderGrabActive.int32]     = ImVec4(0.95f, 0.60f, 0.75f, 1.00f)
  style.colors[ImGuiCol.Button.int32]               = ImVec4(0.45f, 0.25f, 0.35f, 1.00f)
  style.colors[ImGuiCol.ButtonHovered.int32]        = ImVec4(0.65f, 0.35f, 0.50f, 1.00f)
  style.colors[ImGuiCol.ButtonActive.int32]         = ImVec4(0.85f, 0.45f, 0.65f, 1.00f)
  style.colors[ImGuiCol.Header.int32]               = ImVec4(0.45f, 0.25f, 0.35f, 1.00f)
  style.colors[ImGuiCol.HeaderHovered.int32]        = ImVec4(0.55f, 0.30f, 0.45f, 1.00f)
  style.colors[ImGuiCol.HeaderActive.int32]         = ImVec4(0.65f, 0.35f, 0.55f, 1.00f)
  style.colors[ImGuiCol.Tab.int32]                  = ImVec4(0.20f, 0.15f, 0.20f, 1.00f)
  style.colors[ImGuiCol.TabHovered.int32]           = ImVec4(0.65f, 0.35f, 0.50f, 1.00f)
  style.colors[ImGuiCol.TabActive.int32]            = ImVec4(0.45f, 0.25f, 0.35f, 1.00f)
  style.colors[ImGuiCol.Separator.int32]            = ImVec4(0.35f, 0.25f, 0.35f, 1.00f)
  style.colors[ImGuiCol.SeparatorHovered.int32]     = ImVec4(0.65f, 0.35f, 0.50f, 1.00f)
  style.colors[ImGuiCol.SeparatorActive.int32]      = ImVec4(0.85f, 0.45f, 0.65f, 1.00f)
  style.colors[ImGuiCol.TableHeaderBg.int32]        = ImVec4(0.20f, 0.15f, 0.20f, 1.00f)
  style.colors[ImGuiCol.TableBorderStrong.int32]    = ImVec4(0.35f, 0.25f, 0.35f, 1.00f)
  style.colors[ImGuiCol.TableBorderLight.int32]     = ImVec4(0.45f, 0.30f, 0.45f, 1.00f)
  style.colors[ImGuiCol.TableRowBg.int32]           = ImVec4(0.00f, 0.00f, 0.00f, 0.00f)
  style.colors[ImGuiCol.TableRowBgAlt.int32]        = ImVec4(1.00f, 1.00f, 1.00f, 0.04f)
  style.colors[ImGuiCol.PlotLines.int32]            = ImVec4(0.85f, 0.50f, 0.65f, 1.00f)
  style.colors[ImGuiCol.PlotLinesHovered.int32]     = ImVec4(0.95f, 0.60f, 0.75f, 1.00f)
  style.colors[ImGuiCol.PlotHistogram.int32]        = ImVec4(0.85f, 0.50f, 0.65f, 1.00f)
  style.colors[ImGuiCol.PlotHistogramHovered.int32] = ImVec4(0.95f, 0.60f, 0.75f, 1.00f)
  style.colors[ImGuiCol.TextSelectedBg.int32]       = ImVec4(0.95f, 0.60f, 0.75f, 0.35f)
  style.colors[ImGuiCol.NavHighlight.int32]         = ImVec4(0.95f, 0.60f, 0.75f, 1.00f)

#---------------------------------------------------------------------------------------

proc setupCyberpunkStyle*() =
  let style = igGetStyle()

  style.colors[ImGuiCol.Text.int32]                 = ImVec4(0.00f, 1.00f, 0.62f, 1.00f)
  style.colors[ImGuiCol.TextDisabled.int32]         = ImVec4(0.20f, 0.40f, 0.35f, 1.00f)
  style.colors[ImGuiCol.WindowBg.int32]             = ImVec4(0.02f, 0.02f, 0.04f, 1.00f)
  style.colors[ImGuiCol.ChildBg.int32]              = ImVec4(0.02f, 0.02f, 0.04f, 1.00f)
  style.colors[ImGuiCol.PopupBg.int32]              = ImVec4(0.02f, 0.02f, 0.04f, 1.00f)
  style.colors[ImGuiCol.Border.int32]               = ImVec4(1.00f, 0.00f, 0.25f, 0.60f)
  style.colors[ImGuiCol.BorderShadow.int32]         = ImVec4(1.00f, 0.00f, 0.25f, 0.20f)
  style.colors[ImGuiCol.FrameBg.int32]              = ImVec4(0.05f, 0.05f, 0.10f, 1.00f)
  style.colors[ImGuiCol.FrameBgHovered.int32]       = ImVec4(1.00f, 0.00f, 0.25f, 0.20f)
  style.colors[ImGuiCol.FrameBgActive.int32]        = ImVec4(1.00f, 0.00f, 0.25f, 0.40f)
  style.colors[ImGuiCol.TitleBg.int32]              = ImVec4(0.02f, 0.02f, 0.04f, 1.00f)
  style.colors[ImGuiCol.TitleBgActive.int32]        = ImVec4(0.05f, 0.05f, 0.10f, 1.00f)
  style.colors[ImGuiCol.TitleBgCollapsed.int32]     = ImVec4(0.02f, 0.02f, 0.04f, 1.00f)
  style.colors[ImGuiCol.MenuBarBg.int32]            = ImVec4(0.05f, 0.05f, 0.10f, 1.00f)
  style.colors[ImGuiCol.ScrollbarBg.int32]          = ImVec4(0.02f, 0.02f, 0.04f, 1.00f)
  style.colors[ImGuiCol.ScrollbarGrab.int32]        = ImVec4(1.00f, 0.93f, 0.04f, 0.60f)
  style.colors[ImGuiCol.ScrollbarGrabHovered.int32] = ImVec4(1.00f, 0.93f, 0.04f, 0.80f)
  style.colors[ImGuiCol.ScrollbarGrabActive.int32]  = ImVec4(1.00f, 0.93f, 0.04f, 1.00f)
  style.colors[ImGuiCol.CheckMark.int32]            = ImVec4(1.00f, 0.93f, 0.04f, 1.00f)
  style.colors[ImGuiCol.SliderGrab.int32]           = ImVec4(1.00f, 0.00f, 0.25f, 0.80f)
  style.colors[ImGuiCol.SliderGrabActive.int32]     = ImVec4(1.00f, 0.00f, 0.25f, 1.00f)
  style.colors[ImGuiCol.Button.int32]               = ImVec4(0.00f, 1.00f, 0.62f, 0.20f)
  style.colors[ImGuiCol.ButtonHovered.int32]        = ImVec4(0.00f, 1.00f, 0.62f, 0.50f)
  style.colors[ImGuiCol.ButtonActive.int32]         = ImVec4(0.00f, 1.00f, 0.62f, 1.00f)
  style.colors[ImGuiCol.Header.int32]               = ImVec4(1.00f, 0.00f, 0.25f, 0.30f)
  style.colors[ImGuiCol.HeaderHovered.int32]        = ImVec4(1.00f, 0.00f, 0.25f, 0.50f)
  style.colors[ImGuiCol.HeaderActive.int32]         = ImVec4(1.00f, 0.00f, 0.25f, 1.00f)
  style.colors[ImGuiCol.Tab.int32]                  = ImVec4(0.05f, 0.05f, 0.10f, 1.00f)
  style.colors[ImGuiCol.TabHovered.int32]           = ImVec4(1.00f, 0.00f, 0.25f, 0.80f)
  style.colors[ImGuiCol.TabActive.int32]            = ImVec4(0.80f, 0.00f, 0.20f, 1.00f)
  style.colors[ImGuiCol.Separator.int32]            = ImVec4(1.00f, 0.00f, 0.25f, 0.60f)
  style.colors[ImGuiCol.SeparatorHovered.int32]     = ImVec4(1.00f, 0.00f, 0.25f, 1.00f)
  style.colors[ImGuiCol.SeparatorActive.int32]      = ImVec4(1.00f, 0.00f, 0.25f, 1.00f)
  style.colors[ImGuiCol.TableHeaderBg.int32]        = ImVec4(0.05f, 0.05f, 0.10f, 1.00f)
  style.colors[ImGuiCol.TableBorderStrong.int32]    = ImVec4(1.00f, 0.00f, 0.25f, 0.80f)
  style.colors[ImGuiCol.TableBorderLight.int32]     = ImVec4(1.00f, 0.00f, 0.25f, 0.40f)
  style.colors[ImGuiCol.TableRowBg.int32]           = ImVec4(0.00f, 0.00f, 0.00f, 0.00f)
  style.colors[ImGuiCol.TableRowBgAlt.int32]        = ImVec4(1.00f, 1.00f, 1.00f, 0.03f)
  style.colors[ImGuiCol.PlotLines.int32]            = ImVec4(0.00f, 1.00f, 0.62f, 1.00f)
  style.colors[ImGuiCol.PlotLinesHovered.int32]     = ImVec4(0.00f, 1.00f, 0.62f, 1.00f)
  style.colors[ImGuiCol.PlotHistogram.int32]        = ImVec4(1.00f, 0.93f, 0.04f, 1.00f)
  style.colors[ImGuiCol.PlotHistogramHovered.int32] = ImVec4(1.00f, 0.93f, 0.04f, 1.00f)
  style.colors[ImGuiCol.TextSelectedBg.int32]       = ImVec4(1.00f, 0.93f, 0.04f, 0.30f)
  style.colors[ImGuiCol.NavHighlight.int32]         = ImVec4(1.00f, 0.00f, 0.25f, 1.00f)

#---------------------------------------------------------------------------------------

proc setupDosSetupStyle() = 
  let style = igGetStyle()

  style.popupBorderSize   = 1.0f
  style.frameBorderSize   = 1.0f
  style.tabBorderSize     = 1.0f
  style.frameRounding     = 0.0f
  style.scrollbarRounding = 0.0f
  style.grabRounding      = 0.0f

  style.colors[ImGuiCol.Text.int32]                 = ImVec4(1.00f, 1.00f, 1.00f, 1.00f)
  style.colors[ImGuiCol.TextDisabled.int32]         = ImVec4(0.50f, 0.50f, 0.50f, 1.00f)
  style.colors[ImGuiCol.WindowBg.int32]             = ImVec4(0.48f, 0.48f, 0.66f, 1.00f)
  style.colors[ImGuiCol.ChildBg.int32]              = ImVec4(0.48f, 0.48f, 0.66f, 1.00f)
  style.colors[ImGuiCol.PopupBg.int32]              = ImVec4(0.48f, 0.48f, 0.66f, 1.00f)
  style.colors[ImGuiCol.Border.int32]               = ImVec4(0.33f, 1.00f, 1.00f, 0.67f)
  style.colors[ImGuiCol.BorderShadow.int32]         = ImVec4(0.00f, 0.00f, 0.00f, 0.00f)
  style.colors[ImGuiCol.Separator.int32]            = ImVec4(0.33f, 1.00f, 1.00f, 0.67f)
  style.colors[ImGuiCol.SeparatorHovered.int32]     = ImVec4(0.10f, 0.40f, 0.75f, 0.78f)
  style.colors[ImGuiCol.SeparatorActive.int32]      = ImVec4(0.10f, 0.40f, 0.75f, 1.00f)
  style.colors[ImGuiCol.FrameBg.int32]              = ImVec4(0.00f, 0.00f, 0.50f, 1.00f)
  style.colors[ImGuiCol.FrameBgHovered.int32]       = ImVec4(0.00f, 0.66f, 0.66f, 1.00f)
  style.colors[ImGuiCol.FrameBgActive.int32]        = ImVec4(0.00f, 0.50f, 0.50f, 1.00f)
  style.colors[ImGuiCol.TitleBg.int32]              = ImVec4(0.02f, 0.08f, 0.25f, 1.00f)
  style.colors[ImGuiCol.TitleBgActive.int32]        = ImVec4(0.00f, 0.00f, 0.66f, 1.00f)
  style.colors[ImGuiCol.TitleBgCollapsed.int32]     = ImVec4(0.00f, 0.00f, 0.00f, 0.51f)
  style.colors[ImGuiCol.MenuBarBg.int32]            = ImVec4(0.14f, 0.14f, 0.14f, 1.00f)
  style.colors[ImGuiCol.ScrollbarBg.int32]          = ImVec4(0.00f, 0.66f, 0.66f, 1.00f)
  style.colors[ImGuiCol.ScrollbarGrab.int32]        = ImVec4(0.33f, 1.00f, 1.00f, 1.00f)
  style.colors[ImGuiCol.ScrollbarGrabHovered.int32] = ImVec4(1.00f, 1.00f, 1.00f, 1.00f)
  style.colors[ImGuiCol.ScrollbarGrabActive.int32]  = ImVec4(0.90f, 0.90f, 0.90f, 1.00f)
  style.colors[ImGuiCol.CheckMark.int32]            = ImVec4(0.33f, 0.99f, 0.33f, 1.00f)
  style.colors[ImGuiCol.SliderGrab.int32]           = ImVec4(0.00f, 0.66f, 0.66f, 1.00f)
  style.colors[ImGuiCol.SliderGrabActive.int32]     = ImVec4(0.33f, 1.00f, 1.00f, 1.00f)
  style.colors[ImGuiCol.Button.int32]               = ImVec4(0.00f, 0.00f, 0.66f, 1.00f)
  style.colors[ImGuiCol.ButtonHovered.int32]        = ImVec4(0.00f, 0.66f, 0.66f, 1.00f)
  style.colors[ImGuiCol.ButtonActive.int32]         = ImVec4(0.00f, 0.50f, 0.50f, 1.00f)
  style.colors[ImGuiCol.Header.int32]               = ImVec4(0.66f, 0.66f, 0.66f, 1.00f)
  style.colors[ImGuiCol.HeaderHovered.int32]        = ImVec4(0.00f, 0.66f, 0.66f, 1.00f)
  style.colors[ImGuiCol.HeaderActive.int32]         = ImVec4(0.00f, 0.50f, 0.50f, 1.00f)
  style.colors[ImGuiCol.TableHeaderBg.int32]        = ImVec4(0.19f, 0.19f, 0.20f, 1.00f)
  style.colors[ImGuiCol.TableBorderStrong.int32]    = ImVec4(0.31f, 0.31f, 0.35f, 1.00f)
  style.colors[ImGuiCol.TableBorderLight.int32]     = ImVec4(0.23f, 0.23f, 0.25f, 1.00f)
  style.colors[ImGuiCol.TableRowBg.int32]           = ImVec4(0.00f, 0.00f, 0.00f, 0.00f)
  style.colors[ImGuiCol.TableRowBgAlt.int32]        = ImVec4(1.00f, 1.00f, 1.00f, 0.06f)
  style.colors[ImGuiCol.Tab.int32]                  = ImVec4(0.02f, 0.08f, 0.25f, 1.00f)
  style.colors[ImGuiCol.TabHovered.int32]           = ImVec4(0.66f, 0.66f, 0.66f, 1.00f)
  style.colors[ImGuiCol.TabActive.int32]            = ImVec4(0.00f, 0.00f, 0.66f, 1.00f)
  style.colors[ImGuiCol.TabUnfocused.int32]         = ImVec4(0.07f, 0.10f, 0.15f, 0.97f)
  style.colors[ImGuiCol.TabUnfocusedActive.int32]   = ImVec4(0.13f, 0.26f, 0.42f, 1.00f)
  style.colors[ImGuiCol.PlotLines.int32]            = ImVec4(0.61f, 0.61f, 0.61f, 1.00f)
  style.colors[ImGuiCol.PlotLinesHovered.int32]     = ImVec4(1.00f, 0.43f, 0.35f, 1.00f)
  style.colors[ImGuiCol.PlotHistogram.int32]        = ImVec4(0.90f, 0.70f, 0.00f, 1.00f)
  style.colors[ImGuiCol.PlotHistogramHovered.int32] = ImVec4(1.00f, 0.60f, 0.00f, 1.00f)
  style.colors[ImGuiCol.TextSelectedBg.int32]       = ImVec4(0.26f, 0.59f, 0.98f, 0.35f)
  style.colors[ImGuiCol.DragDropTarget.int32]       = ImVec4(1.00f, 1.00f, 0.00f, 0.90f)
  style.colors[ImGuiCol.NavHighlight.int32]         = ImVec4(0.26f, 0.59f, 0.98f, 1.00f)
  style.colors[ImGuiCol.ModalWindowDimBg.int32]     = ImVec4(0.00f, 0.00f, 0.00f, 0.50f)

#---------------------------------------------------------------------------------------

proc setupStyleGeometry*() =
  let style = igGetStyle()
  style.windowPadding             = ImVec2(x: 6f, y: 6f)
  style.framePadding              = ImVec2(x: 10f, y: 6f)
  style.itemSpacing               = ImVec2(x: 7f, y: 7f)
  style.itemInnerSpacing          = ImVec2(x: 1f, y: 1f)
  style.touchExtraPadding         = ImVec2(x: 0f, y: 0f)
  style.selectableTextAlign       = ImVec2(x: 0, y: 0.5f)
  style.windowTitleAlign          = ImVec2(x: 0.5f, y: 0.75f)
  style.indentSpacing             = 6.0f
  style.windowRounding            = 0.0f
  style.frameRounding             = 3.0f
  style.scrollbarRounding         = 16.0f
  style.grabRounding              = 2.0f
  style.grabMinSize               = 20.0f
  style.windowBorderSize          = 1.0f
  style.popupBorderSize           = 0.0f
  style.scrollbarSize             = 12.0f
  style.frameBorderSize           = 0.0f
  style.tabBorderSize             = 0.0f
  style.displaySafeAreaPadding.y  = 0.0f

proc makeResizeGripInvisible*() =
  let style = igGetStyle()
  style.colors[ImGuiCol.ResizeGrip.int32]           = ImVec4(0.00f, 0.00f, 0.00f, 0.00f)
  style.colors[ImGuiCol.ResizeGripHovered.int32]    = ImVec4(0.00f, 0.00f, 0.00f, 0.00f)
  style.colors[ImGuiCol.ResizeGripActive.int32]     = ImVec4(0.00f, 0.00f, 0.00f, 0.00f)



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
    setupDosSetupStyle()
  else:
    setupImGuiDarkStyle()

  makeResizeGripInvisible()


