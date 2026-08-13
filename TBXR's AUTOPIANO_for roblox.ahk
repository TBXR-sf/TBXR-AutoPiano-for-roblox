#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

; ============================================================
;                    TBXR AUTOPIANO
;                    PREMIUM EDITION
; ============================================================

global MainWindow := ""
global NotesInput := ""
global DelayInput := ""
global ThemeInput := ""

global StatusPill := ""
global StatusValue := ""
global CurrentValue := ""
global PlayedValue := ""
global TotalValue := ""
global ProgressBar := ""

global Playing := false
global StopRequested := false

global Events := []
global EventIndex := 0
global Played := 0
global Total := 0
global DelayMs := 100

global RainbowOn := false
global RainbowHue := 0

; ============================================================
; THEME DATABASE
; ============================================================

global Themes := Map(
    "Obsidian",   "0A0A0C",
    "Carbon",     "111214",
    "Graphite",   "1B1D21",
    "Midnight",   "0B1020",
    "Slate",      "20252D",
    "Crimson",    "24080C",
    "Blood Moon", "180508",
    "Cherry",     "280B18",
    "Ocean",      "071923",
    "Arctic",     "101C27",
    "Cyber Blue", "07132B",
    "Violet",     "160D27",
    "Neon Purple", "210B35",
    "Emerald",    "071E18",
    "Toxic",      "152006",
    "Sunset",     "28130A",
    "Gold",       "211A08",
    "Monochrome", "181818",
    "AMOLED",     "000000",
    "Rainbow",    "RAINBOW"
)

; ============================================================
; BOOT SCREEN
; ============================================================

BootWindow := Gui("-Caption +AlwaysOnTop")
BootWindow.BackColor := "070709"

BootWindow.SetFont(
    "s46 Bold cFFFFFF",
    "Segoe UI"
)

BootWindow.AddText(
    "x0 y45 w780 h70 Center",
    "TBXR"
)

BootWindow.SetFont(
    "s11 Bold cAAAAAA",
    "Segoe UI"
)

BootWindow.AddText(
    "x0 y120 w780 h28 Center",
    "AUTOPIANO  /  PREMIUM EDITION"
)

BootWindow.SetFont(
    "s8 c666666",
    "Segoe UI"
)

BootMessage := BootWindow.AddText(
    "x0 y163 w780 h25 Center",
    "INITIALIZING ENGINE..."
)

BootProgress := BootWindow.AddProgress(
    "x145 y205 w490 h6 Range0-100",
    0
)

BootWindow.Show("w780 h285")

BootSteps := [
    "Loading TBXR interface...",
    "Preparing piano engine...",
    "Loading theme library...",
    "Initializing keyboard input...",
    "Starting visual system...",
    "SYSTEM READY."
]

for StepNumber, StepText in BootSteps
{
    BootMessage.Text := StepText

    Loop 16
    {
        BootProgress.Value :=
            ((StepNumber - 1) * 16) + A_Index

        Sleep 10
    }
}

Sleep 300
BootWindow.Destroy()

; ============================================================
; MAIN WINDOW
; ============================================================

MainWindow := Gui(
    "+Resize",
    "TBXR AutoPiano"
)

MainWindow.Opt(
    "+MinSize900x620"
)

MainWindow.BackColor := "0A0A0C"

MainWindow.OnEvent(
    "Close",
    CloseProgram
)

; ============================================================
; HEADER
; ============================================================

MainWindow.SetFont(
    "s25 Bold cFFFFFF",
    "Segoe UI"
)

MainWindow.AddText(
    "x28 y18 w250 h42",
    "TBXR"
)

MainWindow.SetFont(
    "s9 c777777",
    "Segoe UI"
)

MainWindow.AddText(
    "x30 y57 w400 h20",
    "AUTOPIANO  /  PREMIUM ENGINE"
)

; Status pill
StatusPill := MainWindow.AddText(
    "x700 y25 w215 h35 Center c777777 Background17191D",
    "● STANDBY"
)

; ============================================================
; LEFT CONTROL CARD
; ============================================================

MainWindow.AddText(
    "x20 y95 w225 h505 Background111318"
)

MainWindow.SetFont(
    "s9 Bold c888888",
    "Segoe UI"
)

MainWindow.AddText(
    "x38 y115 w190 h20",
    "PLAYBACK"
)

PlayButton := MainWindow.AddButton(
    "x38 y145 w190 h48",
    "▶   PLAY     F6"
)

StopButton := MainWindow.AddButton(
    "x38 y201 w190 h48",
    "■   STOP     F5"
)

PlayButton.OnEvent(
    "Click",
    StartAutoPiano
)

StopButton.OnEvent(
    "Click",
    StopAutoPiano
)

; ============================================================
; DELAY
; ============================================================

MainWindow.SetFont(
    "s9 Bold c888888"
)

MainWindow.AddText(
    "x38 y275 w190 h20",
    "TIMING"
)

DelayInput := MainWindow.AddEdit(
    "x38 y302 w190 h34",
    "100"
)

MainWindow.SetFont(
    "s8 c666666"
)

MainWindow.AddText(
    "x38 y341 w190 h32",
    "Delay between notes (ms)."
)

; ============================================================
; THEME
; ============================================================

MainWindow.SetFont(
    "s9 Bold c888888"
)

MainWindow.AddText(
    "x38 y385 w190 h20",
    "BACKGROUND"
)

ThemeNames := []

for Name, Value in Themes
{
    ThemeNames.Push(Name)
}

ThemeInput := MainWindow.AddDropDownList(
    "x38 y412 w190",
    ThemeNames
)

ThemeInput.Choose(1)

ThemeInput.OnEvent(
    "Change",
    ChangeTheme
)

; ============================================================
; UTILITY BUTTONS
; ============================================================

ClearButton := MainWindow.AddButton(
    "x38 y455 w190 h36",
    "CLEAR SHEET"
)

ExampleButton := MainWindow.AddButton(
    "x38 y499 w190 h36",
    "LOAD EXAMPLE"
)

ClearButton.OnEvent(
    "Click",
    ClearSheet
)

ExampleButton.OnEvent(
    "Click",
    LoadExample
)

MainWindow.SetFont(
    "s8 c444444"
)

MainWindow.AddText(
    "x38 y562 w190 h20 Center",
    "TBXR // 2026"
)

; ============================================================
; SONG EDITOR CARD
; ============================================================

MainWindow.AddText(
    "x260 y95 w700 h440 Background111318"
)

MainWindow.SetFont(
    "s10 Bold cAAAAAA",
    "Segoe UI"
)

MainWindow.AddText(
    "x280 y115 w300 h25",
    "PIANO SHEET"
)

MainWindow.SetFont(
    "s8 c666666",
    "Segoe UI"
)

MainWindow.AddText(
    "x280 y140 w600 h20",
    "Paste your keyboard notes below."
)

MainWindow.SetFont(
    "s10 cDDDDDD",
    "Consolas"
)

NotesInput := MainWindow.AddEdit(
    "x280 y170 w660 h345 +VScroll WantTab",
    ""
)

; ============================================================
; BOTTOM STATS
; ============================================================

MainWindow.AddText(
    "x260 y555 w700 h75 Background111318"
)

MainWindow.SetFont(
    "s8 Bold c666666",
    "Segoe UI"
)

MainWindow.AddText(
    "x280 y567 w110 h18",
    "STATUS"
)

MainWindow.AddText(
    "x430 y567 w110 h18",
    "CURRENT"
)

MainWindow.AddText(
    "x580 y567 w110 h18",
    "PLAYED"
)

MainWindow.AddText(
    "x730 y567 w110 h18",
    "TOTAL"
)

StatusValue := MainWindow.AddText(
    "x280 y588 w110 h22 cFFFFFF",
    "READY"
)

CurrentValue := MainWindow.AddText(
    "x430 y588 w110 h22 cFFFFFF",
    "-"
)

PlayedValue := MainWindow.AddText(
    "x580 y588 w110 h22 cFFFFFF",
    "0"
)

TotalValue := MainWindow.AddText(
    "x730 y588 w110 h22 cFFFFFF",
    "0"
)

ProgressBar := MainWindow.AddProgress(
    "x280 y615 w660 h4 Range0-100",
    0
)

; ============================================================
; HOTKEYS
; ============================================================

F6::StartAutoPiano()
F5::StopAutoPiano()

; ============================================================
; SHOW
; ============================================================

MainWindow.Show(
    "w980 h650"
)

; ============================================================
; START PLAYBACK
; ============================================================

StartAutoPiano(*)
{
    global Playing
    global StopRequested
    global Events
    global EventIndex
    global Played
    global Total
    global DelayMs

    global NotesInput
    global DelayInput

    global StatusPill
    global StatusValue
    global CurrentValue
    global PlayedValue
    global TotalValue
    global ProgressBar

    if Playing
        return

    Sheet := NotesInput.Value

    if Trim(Sheet) = ""
    {
        MsgBox(
            "Paste a piano sheet into the editor first.",
            "TBXR AutoPiano",
            "Icon!"
        )

        return
    }

    DelayMs :=
        ReadDelay(
            DelayInput.Value
        )

    Events :=
        ParseSheet(
            Sheet
        )

    if Events.Length = 0
    {
        MsgBox(
            "No playable notes were detected.",
            "TBXR AutoPiano",
            "Icon!"
        )

        return
    }

    EventIndex := 0
    Played := 0

    Total :=
        CountPlayable(
            Events
        )

    StopRequested := false
    Playing := true

    PlayedValue.Text := "0"
    TotalValue.Text := Total
    CurrentValue.Text := "-"
    ProgressBar.Value := 0

    StatusPill.Text :=
        "● PLAYING"

    StatusPill.SetFont(
        "c00FF88"
    )

    StatusValue.Text :=
        "PLAYING"

    SetTimer(
        PlaybackLoop,
        -10
    )
}

; ============================================================
; PLAYBACK LOOP
; ============================================================

PlaybackLoop(*)
{
    global Playing
    global StopRequested

    global Events
    global EventIndex
    global Played
    global Total
    global DelayMs

    global StatusPill
    global StatusValue
    global CurrentValue
    global PlayedValue
    global ProgressBar

    while Playing && !StopRequested
    {
        EventIndex++

        if EventIndex > Events.Length
        {
            FinishPlayback(true)
            return
        }

        Event :=
            Events[
                EventIndex
            ]

        if Event.Type = "pause"
        {
            WaitInterruptible(
                Event.Duration
            )

            continue
        }

        if Event.Type = "chord"
        {
            for _, Key in Event.Keys
            {
                if !Playing || StopRequested
                    break

                SendPianoKey(Key)
            }
        }
        else
        {
            SendPianoKey(
                Event.Key
            )
        }

        CurrentValue.Text :=
            Event.Display

        Played++

        PlayedValue.Text :=
            Played

        if Total > 0
        {
            ProgressBar.Value :=
                Round(
                    (Played / Total) * 100
                )
        }

        WaitInterruptible(
            DelayMs
        )
    }

    if StopRequested
    {
        FinishPlayback(false)
    }
}

; ============================================================
; STOP
; ============================================================

StopAutoPiano(*)
{
    global Playing
    global StopRequested

    StopRequested := true
    Playing := false

    SetTimer(
        PlaybackLoop,
        0
    )

    FinishPlayback(false)
}

; ============================================================
; FINISH
; ============================================================

FinishPlayback(Completed := false)
{
    global Playing
    global StopRequested

    global StatusPill
    global StatusValue
    global CurrentValue
    global ProgressBar

    Playing := false
    StopRequested := false

    SetTimer(
        PlaybackLoop,
        0
    )

    if Completed
    {
        StatusPill.Text :=
            "● COMPLETE"

        StatusPill.SetFont(
            "c00FF88"
        )

        StatusValue.Text :=
            "COMPLETE"

        ProgressBar.Value :=
            100
    }
    else
    {
        StatusPill.Text :=
            "● STOPPED"

        StatusPill.SetFont(
            "cFF5555"
        )

        StatusValue.Text :=
            "STOPPED"
    }

    CurrentValue.Text := "-"

    SetTimer(
        ResetStatus,
        -1200
    )
}

ResetStatus(*)
{
    global StatusPill
    global StatusValue

    StatusPill.Text :=
        "● STANDBY"

    StatusPill.SetFont(
        "c777777"
    )

    StatusValue.Text :=
        "READY"
}

; ============================================================
; INTERRUPTIBLE WAIT
; ============================================================

WaitInterruptible(Milliseconds)
{
    global Playing
    global StopRequested

    Remaining :=
        Integer(Milliseconds)

    while Remaining > 0
    {
        if !Playing || StopRequested
            return

        Chunk :=
            Min(
                Remaining,
                8
            )

        Sleep Chunk

        Remaining -= Chunk
    }
}

; ============================================================
; SHEET PARSER
; ============================================================

ParseSheet(Text)
{
    Result := []

    Text :=
        StrReplace(
            Text,
            "`r",
            ""
        )

    Text :=
        StrReplace(
            Text,
            "`n",
            ""
        )

    Text :=
        StrReplace(
            Text,
            "`t",
            ""
        )

    Text :=
        StrReplace(
            Text,
            " ",
            ""
        )

    Position := 1
    Length := StrLen(Text)

    while Position <= Length
    {
        Character :=
            SubStr(
                Text,
                Position,
                1
            )

        ; Short pause
        if Character = "|"
        {
            Result.Push({
                Type: "pause",
                Duration: 300,
                Display: "|"
            })

            Position++
            continue
        }

        ; Long pause
        if Character = "~"
        {
            Result.Push({
                Type: "pause",
                Duration: 700,
                Display: "~"
            })

            Position++
            continue
        }

        ; Chord
        if Character = "["
        {
            EndPosition :=
                InStr(
                    Text,
                    "]",
                    false,
                    Position + 1
                )

            if EndPosition
            {
                ChordText :=
                    SubStr(
                        Text,
                        Position + 1,
                        EndPosition - Position - 1
                    )

                Keys := []

                Loop StrLen(ChordText)
                {
                    Key :=
                        SubStr(
                            ChordText,
                            A_Index,
                            1
                        )

                    if IsValidKey(Key)
                    {
                        Keys.Push(Key)
                    }
                }

                if Keys.Length > 0
                {
                    Result.Push({
                        Type: "chord",
                        Keys: Keys,
                        Display: "[" ChordText "]"
                    })
                }

                Position :=
                    EndPosition + 1

                continue
            }
        }

        ; Normal key
        if IsValidKey(Character)
        {
            Result.Push({
                Type: "note",
                Key: Character,
                Display: Character
            })
        }

        Position++
    }

    return Result
}

; ============================================================
; VALID KEY
; ============================================================

IsValidKey(Key)
{
    if RegExMatch(
        Key,
        "^[A-Za-z0-9]$"
    )
    {
        return true
    }

    return InStr(
        "-=[];',./\",
        Key
    ) > 0
}

; ============================================================
; KEY OUTPUT
; ============================================================

SendPianoKey(Key)
{
    if RegExMatch(
        Key,
        "^[a-z]$"
    )
    {
        SendInput(
            "{" Key "}"
        )

        return
    }

    if RegExMatch(
        Key,
        "^[A-Z]$"
    )
    {
        LowerKey :=
            StrLower(Key)

        SendInput(
            "+" LowerKey
        )

        return
    }

    if RegExMatch(
        Key,
        "^[0-9]$"
    )
    {
        SendInput(
            "{" Key "}"
        )

        return
    }

    switch Key
    {
        case "-":
            SendInput("{-}")

        case "=":
            SendInput("{=}")

        case "[":
            SendInput("{[}")

        case "]":
            SendInput("{]}")

        case ";":
            SendInput("{;}")

        case "'":
            SendInput("{'}")

        case ",":
            SendInput("{,}")

        case ".":
            SendInput("{.}")

        case "/":
            SendInput("{/}")

        case "\":
            SendInput("{\}")
    }
}

; ============================================================
; COUNT NOTES
; ============================================================

CountPlayable(List)
{
    Count := 0

    for _, Event in List
    {
        if Event.Type = "note"
            Count++
        else if Event.Type = "chord"
            Count++
    }

    return Count
}

; ============================================================
; DELAY
; ============================================================

ReadDelay(Value)
{
    Value :=
        Trim(Value)

    if !RegExMatch(
        Value,
        "^\d+$"
    )
    {
        return 100
    }

    Number :=
        Integer(Value)

    if Number < 1
        Number := 1

    if Number > 10000
        Number := 10000

    return Number
}

; ============================================================
; CLEAR
; ============================================================

ClearSheet(*)
{
    global NotesInput
    global PlayedValue
    global TotalValue
    global CurrentValue
    global ProgressBar

    StopAutoPiano()

    NotesInput.Value := ""

    PlayedValue.Text := "0"
    TotalValue.Text := "0"
    CurrentValue.Text := "-"
    ProgressBar.Value := 0
}

; ============================================================
; EXAMPLE
; ============================================================

LoadExample(*)
{
    global NotesInput

    NotesInput.Value :=
        "asdfghj`n"
        . "jhgfdsa|"
        . "asdfjkl`n"
        . "[ad][sf][dg][fh]`n"
        . "jhgfdsa~"
        . "asdfghj"
}

; ============================================================
; THEME ENGINE
; ============================================================

ChangeTheme(*)
{
    global ThemeInput
    global Themes
    global RainbowOn

    Selected :=
        ThemeInput.Text

    RainbowOn := false

    SetTimer(
        RainbowTick,
        0
    )

    if !Themes.Has(Selected)
        return

    ThemeColor :=
        Themes[Selected]

    if ThemeColor = "RAINBOW"
    {
        RainbowOn := true

        SetTimer(
            RainbowTick,
            25
        )

        return
    }

    ApplyTheme(
        ThemeColor
    )
}

; ============================================================
; APPLY THEME
; ============================================================

ApplyTheme(Color)
{
    global MainWindow

    MainWindow.BackColor :=
        Color
}

; ============================================================
; SMOOTH RAINBOW
; ============================================================

RainbowTick(*)
{
    global RainbowOn
    global RainbowHue
    global MainWindow

    if !RainbowOn
        return

    RainbowHue += 1.2

    if RainbowHue >= 360
        RainbowHue := 0

    MainWindow.BackColor :=
        HSV(
            RainbowHue,
            0.72,
            0.11
        )
}

; ============================================================
; HSV COLOR
; ============================================================

HSV(H, S, V)
{
    C :=
        V * S

    X :=
        C * (
            1 -
            Abs(
                Mod(
                    H / 60,
                    2
                ) - 1
            )
        )

    M :=
        V - C

    if H < 60
    {
        R := C
        G := X
        B := 0
    }
    else if H < 120
    {
        R := X
        G := C
        B := 0
    }
    else if H < 180
    {
        R := 0
        G := C
        B := X
    }
    else if H < 240
    {
        R := 0
        G := X
        B := C
    }
    else if H < 300
    {
        R := X
        G := 0
        B := C
    }
    else
    {
        R := C
        G := 0
        B := X
    }

    R :=
        Round(
            (R + M) * 255
        )

    G :=
        Round(
            (G + M) * 255
        )

    B :=
        Round(
            (B + M) * 255
        )

    return Format(
        "{:02X}{:02X}{:02X}",
        R,
        G,
        B
    )
}

; ============================================================
; CLOSE
; ============================================================

CloseProgram(*)
{
    global Playing
    global RainbowOn

    Playing := false
    RainbowOn := false

    SetTimer(
        PlaybackLoop,
        0
    )

    SetTimer(
        RainbowTick,
        0
    )

    ExitApp()
}