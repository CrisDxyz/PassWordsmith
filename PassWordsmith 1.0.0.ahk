#Requires AutoHotkey v2.0
#SingleInstance Force
;==Testing&Debug==
;#Warn All
;#Warn LocalSameAsGlobal, OutputDebug
;==Sets==
;SetWorkingDir A_ScriptDir ; Default

/*
===============================================================
PassWordsmith - Mastering the Art of Password Forging
===============================================================
Version: 1.0.0
Created by: CrisDxyz
Date: Today
License: MIT License

===============================================================
Description:
This script generates secure passwords and passphrases with 
customizable options, including character types, word themes, 
and separators. It also provides features for password strength 
evaluation, saving to a database, and creating decoy files.

===============================================================
Credits and Acknowledgments:
- Concept and Development: CrisDxyz (Me)
- Language and Theme Word Lists: 
  - English: https://github.com/dwyl/english-words/tree/master
  - Spanish: https://github.com/JorgeDuenasLerin/diccionario-espanol-txt/tree/master
  - Themed Word Lists: Self-Created, with help of ML.
- Credits of black windows frame to u/plankoe
- Inspired by https://xkcd.com/936/ and using other password generators, like Avast (https://www.avast.com/random-password-generator#pc)

===============================================================
Disclaimer:
This tool is provided "as is," without warranty of any kind. 
The password database is stored in plain text; it is your 
responsibility to ensure its security. Use at your own risk.

===============================================================
*/

;==Create the main GUI==
PassGUI := Gui("+Resize", "PassWordsmith - Mastering the Art of Password Forging")
PassGUI.SetFont("cWhite")
PassGUI.SetFont("s10", "Arial")
PassGUI.BackColor := "101010"

SetDarkWindowFrame(PassGUI) ; credits of frame to u/plankoe

SetDarkWindowFrame(hwnd, boolEnable:=1) {
    hwnd := WinExist(hwnd)
    if VerCompare(A_OSVersion, "10.0.17763") >= 0
        attr := 19
    if VerCompare(A_OSVersion, "10.0.18985") >= 0
        attr := 20
    DllCall("dwmapi\DwmSetWindowAttribute", "ptr", hwnd, "int", attr, "int*", boolEnable, "int", 4)
}

; Create tabs for different generation modes
tabs := PassGUI.Add("Tab3", "w500 h400", ["Random Password", "Passphrase", "Settings"])

; ========== Random Password Tab ==========
tabs.UseTab(1)

PassGUI.Add("Text", "x+20 y+10", "Password Length ")
lengthSlider := PassGUI.Add("Slider", "vSlider x+10 w200 Range1-50", 15)
lengthEdit := PassGUI.Add("Edit", "vEditText Background404040 " "x+10 w50 Number", "15")
lengthText := PassGUI.Add("Text", "x+5 w30 yp+5", "Characters")

; Custom Rules group box
PassGUI.Add("GroupBox", "xm+1 yp+25 w500 h80", " Prefix and Suffix Custom Rules (Optional, works in Passwords and Passphrases) ")
PassGUI.Add("Text", "xm+90 yp+35", "Prefix:")
prefixEdit := PassGUI.Add("Edit", "Background404040 " "x+5 yp-3 w100")
PassGUI.Add("Text", "x+10 yp+3", "Suffix:")
suffixEdit := PassGUI.Add("Edit", "Background404040 " "x+5 yp-3 w100")

; Checkboxes for character sets
PassGUI.Add("Text","xm+10 y+15", " Include characters ")
chkUppercase := PassGUI.Add("Checkbox", "xm+25 y+15 Checked", "Uppercase (A-Z)")
chkLowercase := PassGUI.Add("Checkbox", "xm+25 y+10 Checked", "Lowercase (a-z)")
chkNumbers := PassGUI.Add("Checkbox", "xm+25 y+10 Checked", "Numbers (0-9)")
chkSpecial := PassGUI.Add("Checkbox", "xm+25 y+10 Checked", "Special (!@#$%^&*(){}[]-+=¿?)")

; ========== Passphrase Tab ==========
tabs.UseTab(2)
PassGUI.Add("Text",, "Number of Words:")
wordCountEdit := PassGUI.Add("Edit", "Background404040 " "x+10 y+-20 w50 Number", "3")
PassGUI.Add("Text","xp+60 yp+4", "(Limit of 4100 words, Mnemonics use only 3) ")

; Add homoglyph checkbox
chkHomoglyphs := PassGUI.Add("Checkbox", "xm+15 y+10", "Use character substitutions/homoglyphs (e.g., o→0, i→1, k→|<)")

; Create GroupBox for word lists
PassGUI.Add("GroupBox", "xm y+10 w500 h210", " Word Sources ")

; Language word lists
PassGUI.Add("Text", "xm+20 yp+25", "Language Lists:")
chkEnglishWords := PassGUI.Add("Checkbox", "x+10 yp+2", "English")
chkSpanishWords := PassGUI.Add("Checkbox", "x+10 yp", "Spanish")

; Themed word lists
PassGUI.Add("Text", "xm+10 y+10", "Themes:")

; Column 1
chkAnimals := PassGUI.Add("Checkbox", "xm+10 y+5", "Animals")
chkAstronomy := PassGUI.Add("Checkbox", "xm+10 y+5", "Astronomy")
chkCyberpunk := PassGUI.Add("Checkbox", "xm+10 y+5", "Cyberpunk")
chkFantasy := PassGUI.Add("Checkbox", "xm+10 y+5", "Fantasy")

; Column 2
chkMedieval := PassGUI.Add("Checkbox", "x+60 yp-63", "Medieval")
chkMusic := PassGUI.Add("Checkbox", "yp+21", "Music")
chkOlympian := PassGUI.Add("Checkbox", "yp+21", "Olympian")
chkPirate := PassGUI.Add("Checkbox", "yp+21", "Pirate")

; Column 3
chkScifi := PassGUI.Add("Checkbox", "x+60 yp-63", "Sci-Fi")
chkSuperhero := PassGUI.Add("Checkbox", "yp+21", "Superhero")
chkTechBuzz := PassGUI.Add("Checkbox", "yp+21", "Tech Buzzwords")
chkViking := PassGUI.Add("Checkbox", "yp+21", "Viking")

; Separator options 
PassGUI.Add("Text", "xm+10 y+48", " Word Separators ")
chkSepNumbers := PassGUI.Add("Checkbox", "xm+15 y+15", "Numbers (0-9)")
chkSepSpecial := PassGUI.Add("Checkbox", "x+10 yp", "Special (!@#$%^&*(){}[]-+=¿?)")

; Re-roll mnemonic button to the Passphrase tab
PassGUI.Add("Text", "xm+10 y+20", " Awful Mnemonic? ")
PassGUI.Add("Button", "x+10 yp-5 w120", "Re-roll Mnemonic").OnEvent("Click", ReRollMnemonic)

; ========== Settings Tab ==========
tabs.UseTab(3)

; Group box for file settings
PassGUI.Add("GroupBox", "xm y+10 w500 h150", " Password Database Settings ")

; Save checkbox to settings tab
chkSaveToFile := PassGUI.Add("Checkbox", "xm+10 yp+30", "Save passwords to database (system_logs.txt)")

; File visibility toggle button
btnToggleFile := PassGUI.Add("Button", "xm+10 y+10 w180", " Toggle Database Visibility ")

; Status text for file visibility
fileStatusText := PassGUI.Add("Text", "x+10 yp+5 w200", " Status: Checking... ")

; Help button
PassGUI.Add("GroupBox", "xm y+40 w500 h80", " Help && Information ")
btnHelp := PassGUI.Add("Button", "xm+10 yp+40 w30 h30", "?")
PassGUI.Add("Text", "x+10 yp+7", "Click for help and password security best practices")
btnDecoy := PassGUI.Add("Button", "xp+100 yp+95 w200", "Generate Decoy Files")

; ========== Common Controls (outside tabs) ==========
tabs.UseTab()

; Password display
PassGUI.Add("Text", "xm y+110", "Password generated: ")
passwordEdit := PassGUI.Add("Edit", "Background404040 " "xm y+5 w480 ReadOnly Center", "")

; Hint display edit box
PassGUI.Add("Text", "xm y+5", "Hint (Mnemonic) to help you remember the passphrase: ")
hintEdit := PassGUI.Add("Edit", "Background404040 " "xm y+10 w500 ReadOnly Multi Center", "")
hintEdit.Opt("+Wrap")  ; Enable text wrapping

; Password strength meter
PassGUI.Add("Text", "xm y+10", "Password Strength:")
strengthProgress := PassGUI.Add("Progress", "x+10 w200 h20 cRed", 0)
strengthText := PassGUI.Add("Text", "x+10 yp+2", "No password generated")

; Buttons
btnGenerate := PassGUI.Add("Button", "xm+100 y+25 w140", "Generate")
btnCopy := PassGUI.Add("Button", "x+20 w140", "Copy to Clipboard")

; Event handlers
lengthSlider.OnEvent("Change", UpdateLengthFromSlider)
lengthEdit.OnEvent("Change", UpdateLengthFromEdit)

btnGenerate.OnEvent("Click", GenerateOutput)
btnCopy.OnEvent("Click", CopyOutput)
btnHelp.OnEvent("Click", ShowHelp)
btnDecoy.OnEvent("Click", GenerateDecoyFiles)
btnToggleFile.OnEvent("Click", ToggleFileVisibility)
tabs.OnEvent("Change", (*) => UpdateFileStatus())

; Initial file status check
SetTimer(UpdateFileStatus, -100)

; Show the GUI
PassGUI.Show()

; Global variables for word lists
englishWords := []
spanishWords := []
themeWords := Map(
    "animals", [],
    "astronomy", [],
    "cyberpunk", [],
    "fantasy", [],
    "medieval", [],
    "music", [],
    "olympian", [],
    "pirate", [],
    "scifi", [],
    "superhero", [],
    "techbuzz", [],
    "viking", []
)

; Mnemonic storage for reroll
global lastPassphraseWords := []

; Load word lists on startup
LoadWordList(filename, wordArray) {
    try {
        Loop Read, filename
            wordArray.Push(Trim(A_LoopReadLine))
        return true
    } catch as err {
        return false
    }
}

; Load language lists
if !LoadWordList("Words_list_english.txt", englishWords)
    MsgBox("Warning: Could not load english_words.txt", "Warning", "Icon!")
if !LoadWordList("Lista_palabras_espanol.txt", spanishWords)
    MsgBox("Warning: Could not load spanish_words.txt", "Warning", "Icon!")

; Load theme lists
for theme, arr in themeWords {
    if !LoadWordList(theme . "-wordlist.txt", arr)
        MsgBox("Warning: Could not load " . theme . "_words.txt", "Warning", "Icon!")
}


; Function to check file visibility status
UpdateFileStatus() {
    try {
        if FileExist("system_logs.txt") {
            attrib := FileGetAttrib("system_logs.txt")
            if InStr(attrib, "H")
                fileStatusText.Value := " Status: Files are Hidden "
            else
                fileStatusText.Value := " Status: Files are Visible "
        }
        else if FileExist("desktop.ini") {
            fileStatusText.Value := "Status: File is Hidden"
        }
        else {
            fileStatusText.Value := "Status: File Not Found"
        }
    } catch as err {
        fileStatusText.Value := "Status: Error checking file"
    }
}

; Function to toggle file visibility and rename
ToggleFileVisibility(*) {
    try {
        currentName := "system_logs.txt"
        hiddenName := "desktop.ini"
        
        ; First handle the main password file
        if FileExist(currentName) {
            ; File is visible, hide and rename it
            FileSetAttrib("+H", currentName)
            FileMove(currentName, hiddenName)
            ; Set file to system only
            ;FileSetAttrib("+S", currentName)
        }
        ; Check if hidden file exists
        else if FileExist(hiddenName) {
            ; File is hidden, make visible and rename it
            FileSetAttrib("-H", hiddenName)
            FileMove(hiddenName, currentName)
            ; Unset file as system file
            ;FileSetAttrib("-S", hiddenName) 
        }
        
        ; --Handle decoy files
        ; Check for plain text files
        if FileExist("passwords_*.txt"){
            Loop Files, "passwords_*.txt" {
                visibleName := A_LoopFileName
                ; log _ year + month + day + _ + hour24f + min + sec + rand(num) || replace id with rand? erase?
                hiddenName := "log_" . Random(2021, 2025) . Random(1, 9) . Random(10, 28) . "_" . Random(10, 24) . Random(10, 60) . Random(10, 60) . ".txt" ; Remove "sys log" prefix
                ;MsgBox("Nombre V: " . visibleName . "Nombre H: " . hiddenName)
                ; Hide visible file
                FileSetAttrib("+H", visibleName)
                FileMove(visibleName, hiddenName)
            }
        }

        ; Find all potential decoy files (both visible and hidden)
        ; Check for hidden decoy files
        else if FileExist("log_*.txt") {
            Loop Files, "log_*.txt" {
                hiddenName := A_LoopFileName
                visibleName := "passwords_" . SubStr(hiddenName, 5)  ; Remove "log" prefix
                ;MsgBox("Nombre V: " . visibleName . "Nombre H: " . hiddenName)
                ; Make hidden file visible
                FileSetAttrib("-H", hiddenName)
                FileMove(hiddenName, visibleName)
            }
        }

        ; Update status message based on current state
        if FileExist("desktop.ini") && FileExist("log_*.txt") {
            MsgBox("Password databases are now hidden.", "Success", "Iconi")
        } else {
            MsgBox("Password databases are now visible.", "Success", "Iconi")
            return
        }

        UpdateFileStatus()
    } catch as err {
        MsgBox("Error toggling file visibility: " . err.Message, "Error", "Icon!")
    }
}


; Function to calculate password strength (0-100)
CalculatePasswordStrength(password)
{
    if (password = "")
        return 0
    
    strength := 0
    length := StrLen(password)
    
    ; Length contribution (up to 100 points, in case it's really long)
    strength += Min(length * 1.7, 100)
    
    ; Character variety contribution (up to 52 points)
    hasLower := RegExMatch(password, "[a-z]")
    hasUpper := RegExMatch(password, "[A-Z]")
    hasNumber := RegExMatch(password, "\d")
    hasSpecial := RegExMatch(password, "[^a-zA-Z0-9]")
    
    variety := (hasLower ? 1 : 0) + (hasUpper ? 1 : 0) + 
               (hasNumber ? 1 : 0) + (hasSpecial ? 1 : 0)
    
    strength += variety * 13
    
    ; Word-based bonus for passphrases
    wordCount := (StrSplit(password, " ").Length + 
                 StrSplit(password, "!").Length +
                 StrSplit(password, "@").Length - 2)
    if (wordCount > 1)
        strength += Min(wordCount * 10, 30)
    
    ; Ensure maximum is 100
    return Min(strength, 100)
}

; Function to update strength meter
UpdateStrengthMeter(password)
{
    strength := CalculatePasswordStrength(password)
    strengthProgress.Value := strength
    
    ; Update color and text based on strength
    if (strength < 30) {
        strengthProgress.Opt("cRed")
        strengthText.Value := "Very Weak"
    } else if (strength < 50) {
        strengthProgress.Opt("cMaroon")
        strengthText.Value := "Weak"
    } else if (strength < 65) {
        strengthProgress.Opt("cYellow")
        strengthText.Value := "Moderate"
    } else if (strength < 85) {
        strengthProgress.Opt("cLime")
        strengthText.Value := "Strong"
    } else {
        strengthProgress.Opt("cGreen")
        strengthText.Value := "Very Strong"
    }
    
    ; Add specific suggestions for improvement
    if (strength < 75) {
        tips := "Tips: "
        if (StrLen(password) < 15)
            tips .= "Increase length. "
        if (!RegExMatch(password, "[A-Z]"))
            tips .= "Add uppercase. "
        if (!RegExMatch(password, "[a-z]"))
            tips .= "Add lowercase. "
        if (!RegExMatch(password, "\d"))
            tips .= "Add numbers. "
        if (!RegExMatch(password, "[^a-zA-Z0-9]"))
            tips .= "Add special chars. "

        ToolTip(tips)
        SetTimer () => ToolTip(), -3000  ; Hide tooltip after 3 seconds
    }
}


; Function to update length from edit box
UpdateLengthFromEdit(*)
{
    try {
        ; Attempt to convert edit text to integer
        value := Integer(lengthEdit.Text)
        
        ; Clamp value between 1 and 50
        value := Max(1, Min(value, 50))
        
        ; Update both slider and edit control
        value := Integer(lengthEdit.Text)
        ; Update slider to match edit value
        lengthSlider.Value := value
        if (value>50){
            lengthEdit.Text := 50
        }
        ;if (!value or value=""){ ; if 0 or empty, then 1. it makes editing slightly annoying to manually type
        ;    lengthEdit.Text := 1
        ;}
    }
    catch {
        ; If conversion fails, reset edit to slider's value
        ; conversion will always "fail" when the edit box is empty, so commenting it for now
        ;lengthEdit.Text := lengthSlider.Value
    }
}

; Function to update length from slider
UpdateLengthFromSlider(*)
{
    lengthEdit.Value := lengthSlider.Value
}


; Function to generate random separator
GenerateSeparator()
{
    chars := ""
    if chkSepNumbers.Value
        chars .= "0123456789"
    if chkSepSpecial.Value
        chars .= "!@#$%^&*(){}[]-+=¿?"
    
    if chars = ""
        return ""
    
    return SubStr(chars, Random(1, StrLen(chars)), 1)
}

; Function to generate output (password or passphrase)
GenerateOutput(*)
{
    if (tabs.Value = 1)
        GeneratePassword()
    else
        GeneratePassphrase()
}

; Function to generate password
GeneratePassword()
{
    chars := ""
    
    ; Build character set based on selections
    if chkUppercase.Value
        chars .= "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    if chkLowercase.Value
        chars .= "abcdefghijklmnopqrstuvwxyz"
    if chkNumbers.Value
        chars .= "0123456789"
    if chkSpecial.Value
        chars .= "!@#$%^&*(){}[]-+=¿?"
    
    ; Check if at least one character set is selected
    if chars = ""
    {
        MsgBox("Please select at least one character set.", "Error", "Icon!")
        return
    }
    
    ; Get prefix and suffix
    prefix := prefixEdit.Value
    suffix := suffixEdit.Value
    
    ; Calculate remaining length for random part
    remainingLength := lengthSlider.Value - StrLen(prefix) - StrLen(suffix)
    
    ; Check if there's enough room for random characters
    if (remainingLength < 0)
    {
        MsgBox("Prefix and suffix combined are longer than the total desired length. Please adjust.", "Error", "Icon!")
        return
    }
    
    ; Generate random part
    password := prefix  ; Start with prefix
    Loop remainingLength
    {
        random_index := Random(1, StrLen(chars))
        password .= SubStr(chars, random_index, 1)
    }
    password .= suffix  ; Add suffix
    
    passwordEdit.Value := password
    UpdateStrengthMeter(passwordEdit.Value)
}

; Add homoglyph substitution function
SubstituteHomoglyphs(text) {
    substitutions := Map(
        "a", "4",
        "b", "6",
        "e", "3",
        "g", "9",
        "i", "1",
        "l", "1",
        "o", "0",
        "s", "5",
        "t", "7",
        "z", "2",
        "h", "#",
        "x", "%",
        "k", "|<",
        "t", "+",
        "v", "\/",
        "w", "\^/",
        "r", "|2",
    )
    
    result := ""
    Loop Parse, text {
        ; Random chance (50%) to substitute if the character has a valid substitution
        if (substitutions.Has(StrLower(A_LoopField)) && Random(1, 2) = 1)
            result .= substitutions[StrLower(A_LoopField)]
        else
            result .= A_LoopField
    }
    return result
}

GenerateMnemonic(words, theme) {
    ; Define theme-specific mnemonic templates related to dicts.
    themeTemplates := Map(
        "animals", [
            "In the wild kingdom of {1}, {2} and {3} dance their eternal ballet",
            "The graceful stride of {1}, shadowed by {2}, and guided by {3}",
            "In the wild, {1} stalks near {2}, hiding from {3}'s sharp eyes",
            "A playful chase between {1} and {2}, watched by {3} from above",
            "The roar of {1} echoes through {2}'s den, met by {3}'s call",
            "Through the jungle, {1} leaps past {2}, drawn to {3}'s scent",
            "The quiet strength of {1}, standing guard over {2}, alongside {3}",
            "In the savannah, {1} watches {2} graze, while {3} circles above",
            "The forest whispers of {1}, gliding past {2}, toward {3}'s shelter",
            "Tracks of {1} lead through {2}'s meadow, disappearing near {3}",
            "The pack moves as {1} howls to {2}, echoing in {3}'s valley",
            "The calm of {1} rests under {2}'s shade, joined by {3}",
            "A hunt begins as {1} searches for {2}, while {3} lurks nearby",
            "In the moonlight, {1} hides from {2}'s chase, unaware of {3}",
            "The skies open as {1} soars past {2}, diving toward {3}'s prey",
            "The call of {1} blends with {2}'s cry, carried by {3}'s wind",
            "Among the reeds, {1} hides from {2}, beneath {3}'s shadow",
            "The herd follows {1} to {2}'s clearing, surrounded by {3}'s watch",
            "Through the tundra, {1} trudges near {2}, seeking {3}'s warmth",
            "The quiet prowl of {1} skirts {2}'s lair, heading for {3}"
        ],
        "astronomy", [
            "Cosmic harmony of {1}, illuminated by the {2} star, anchored by {3}",
            "Starborn prophecy of {1}, echoing through {2} and {3}'s constellation",
            "Galactic voyage: {1} traverses the nebula of {2}, guided by the beacon of {3}",
            "Stellar dance of {1} around the magnetic pull of {2}, shadowed by {3}'s glow",
            "Nebular glow of {1}, traced by the stardust of {2}, resting near {3}",
            "Shimmering trail of {1}, drawn to the pulsating light of {2}, shadowed by {3}",
            "The universe unfolds with {1}, drifting across {2}'s skies, watched by {3}",
            "Luminous patterns of {1}, as {2} aligns within {3}'s astral embrace",
            "The night whispers {1}, carried by {2}'s glow, ending at {3}'s edge",
            "A silent journey of {1}, guided by {2}'s starlight, cradled by {3}'s presence",
            "Ancient tales of {1}, spun by the winds of {2}, shining in {3}'s galaxy",
            "Celestial balance of {1}, tipping toward {2}'s horizon, centered by {3}",
            "The vast expanse welcomes {1}, crossing {2}'s light path to reach {3}",
            "Eternal brightness of {1}, blending with the orbit of {2}, caught by {3}'s gravity",
            "The heavens shimmer with {1}, drawn by {2}'s alignment, circled by {3}",
            "Timeless echoes of {1}, resonating in {2}'s realm, framed by {3}'s radiance",
            "The stars shine brighter with {1}, flaring through {2}'s clusters to {3}'s beacon",
            "The universe breathes {1}, shaped by the pull of {2}, glowing near {3}",
            "A cosmic melody of {1}, written by {2}'s light, flowing through {3}'s constellation",
            "The night sky frames {1}, surrounded by the aura of {2}, reflecting {3}'s brilliance",
            "Infinite skies hold {1}, born in the cradle of {2}, under the watchful gaze of {3}",
            "The cosmos whispers of {1}, unfolding the mysteries of {2} near {3}'s galaxy",
            "Nebular embrace of {1}, as {2} collides with the brilliance of {3}",
            "Interstellar chronicles of {1}, scripted by the eclipses of {2} and the orbit of {3}",
            "The infinite expanse cradles {1}, serenaded by {2}'s celestial chords, drawn to {3}'s horizon",
            "The radiant glow of {1}, reflected in the {2} nebula, warmed by {3}'s fire",
            "The quiet brilliance of {1} shines through {2}, meeting the light of {3}",
            "The heavens tell of {1}, spinning gently in {2}'s orbit, drawn by {3}",
            "A cosmic river flows from {1}, through the heart of {2}, ending at {3}",
            "The stars whisper of {1}, traveling to {2}, resting in {3}'s embrace",
            "In the vast expanse, {1} shines alongside {2}, guided by the glow of {3}",
            "A silent journey begins with {1}, tracing the arc of {2} toward {3}",
            "In the deep sky, {1} follows the trail of {2}, encircled by {3}'s halo",
            "The universe is alive with {1}, orbiting {2}'s beacon, blessed by {3}'s light",
            "Through the void, {1} connects with {2}, carried on the waves of {3}",
            "The night sky holds {1}, dancing near {2}, forever linked to {3}",
            "A celestial thread ties {1} to {2}, woven through the brilliance of {3}",
            "The endless cosmos cradles {1}, bound to {2}, lit by {3}'s ancient glow",
            "The stars align for {1}, marking the path through {2} to {3}",
            "Galaxies collide where {1} meets {2}, under the watchful gaze of {3}",
            "The starlit journey of {1}, alongside {2}, leads to the glow of {3}",
            "Across the nebula, {1} shines with the fire of {2}, enveloped by {3}'s radiance",
            "The universe expands with {1}, as {2} weaves starlight through the void of {3}",
            "Astral beacon of {1}, illuminating the path to {2}'s cluster, marked by {3}'s orbit",
            "Constellation symphony of {1}, harmonized by {2}'s stars and {3}'s galactic winds",
            "Dark matter veil of {1}, pierced by {2}'s photons, enveloped by {3}'s radiance",
            "Beyond the Milky Way, {1} collides with the remnants of {2}, held by {3}'s supernova light"
        ],
        "cyberpunk", [
            "Rogue algorithms of {1}, networked through {2}, secured by {3}",
            "The neon haze of {1} pulses in the alleys of {2}, guided by {3}'s code",
            "Through the datastream, {1} encrypts {2}, while {3} monitors the grid",
            "The hum of {1} echoes in {2}'s circuits, powered by {3}'s core",
            "A renegade AI named {1} hacks into {2}, leaving traces near {3}",
            "In the megacity, {1} evades {2}'s drones, disappearing into {3}'s shadows",
            "The digital skyline of {1} reflects in {2}, fractured by {3}'s virus",
            "A rogue signal from {1} disrupts {2}'s firewall, opening {3}'s mainframe",
            "Under the flickering sign of {1}, {2} trades secrets with {3}",
            "The black market thrives as {1} exchanges {2}'s chip for {3}'s credits",
            "In the undercity, {1} bypasses {2}'s lock, breaking into {3}",
            "The neural implant of {1} syncs with {2}, unlocking {3}'s network",
            "A cybernetic pulse from {1} overrides {2}'s system, rerouting to {3}",
            "On the skyline, {1} leaps across {2}'s rooftops, chased by {3}'s drones",
            "A whispered code from {1} reaches {2}, triggering {3}'s cascade failure",
            "In the virtual void, {1} encounters {2}'s avatar, shaped by {3}'s algorithm",
            "The hack begins as {1} uploads {2}'s payload, crashing {3}'s server",
            "In the shadow of the spire, {1} reprograms {2}, preparing for {3}'s heist",
            "The digital rebellion starts with {1}, spreading through {2}, and crashing {3}",
            "Among the neon ruins, {1} discovers {2}'s relic, encoded with {3}'s data"
        ],
        "fantasy", [
            "From the sagas of {1}, blessed by {2} gods, guarded by the spirit of {3}",
            "Magical realm where {1} meets {2}, under the eternal watch of {3}",
            "Ancient prophecy of {1}, empowered by {2}, sealed with {3}'s magic"
            "The sword of {1} gleams in {2}'s forge, blessed by {3}'s spell",
            "In the ancient forest, {1} meets {2}, under the watch of {3}",
            "The kingdom whispers of {1}, guarded by {2}, and sought by {3}",
            "Through the enchanted woods, {1} follows {2}'s trail, guided by {3}'s light",
            "The wizard {1} wields {2}'s staff, channeling the power of {3}",
            "A dragon's roar echoes as {1} defends {2}, with {3} in their heart",
            "The prophecy speaks of {1}, hidden within {2}'s ruins, alongside {3}",
            "The ancient tome of {1} rests in {2}, protected by {3}'s ward",
            "The hero {1} ventures into {2}'s caves, seeking {3}'s treasure",
            "The castle gates open for {1}, as {2} waits inside, with {3}'s blessing",
            "The magical flame of {1} burns in {2}'s lantern, lighting {3}'s path",
            "On the battlefield, {1} stands with {2}, against {3}'s forces",
            "The elven bow of {1} strikes true in {2}'s glade, watched by {3}",
            "The hidden grove of {1} blooms with {2}'s flowers, fed by {3}'s stream",
            "The enchanted blade of {1} shatters {2}'s chains, freeing {3}",
            "A knight's oath binds {1} to {2}, in service of {3}'s realm",
            "The mountain peak of {1} hides {2}'s shrine, blessed by {3}'s storm",
            "The magic of {1} flows through {2}'s runes, binding {3}'s destiny",
            "The griffin of {1} soars over {2}, guarding the relic of {3}"
        ],
        "medieval", [
            "Knightly tale of {1}, honored by {2}, defended by the realm of {3}",
            "Echoes from the castle of {1}, whispers of {2}, legends of {3}",
            "The banner of {1} flies over {2}'s keep, guarded by {3}'s knights",
            "In the royal court, {1} pledges loyalty to {2}, witnessed by {3}",
            "The blacksmith {1} forges {2}'s blade, destined for {3}'s war",
            "The town crier proclaims {1}'s deeds across {2}, echoing in {3}'s halls",
            "The squire {1} trains under {2}, dreaming of {3}'s battlefield",
            "The castle gates of {1} open to {2}'s caravan, bearing {3}'s riches",
            "The feast at {1}'s hall honors {2}, with tales of {3}'s valor",
            "The shield of {1} reflects {2}'s lance, under {3}'s watchful eye",
            "The village of {1} prospers near {2}'s river, blessed by {3}'s harvest",
            "The knight {1} rides to {2}'s stronghold, carrying {3}'s message",
            "In the dungeon, {1} uncovers {2}'s secret, hidden by {3}'s chains",
            "The crown of {1} rests upon {2}'s brow, forged by {3}'s decree",
            "The bard {1} sings of {2}'s triumphs, echoing in {3}'s tavern",
            "The marketplace of {1} bustles with {2}'s wares, overseen by {3}",
            "The trebuchet of {1} rains down upon {2}, shaking {3}'s defenses",
            "The monastery of {1} guards {2}'s relic, protected by {3}'s faith",
            "The oath of {1} binds them to {2}'s service, under {3}'s flag",
            "The royal decree of {1} grants {2} dominion over {3}'s lands",
            "The joust begins as {1} charges {2}, cheered on by {3}'s crowd"
        ],
        "music", [
            "Symphony of {1}, resonating with {2}, conducted by the rhythm of {3}",
            "The melody of {1} flows through {2}'s strings, guided by {3}'s rhythm",
            "In the concert hall, {1} harmonizes with {2}, echoing {3}'s song",
            "The notes of {1} dance on {2}'s keys, lifted by {3}'s tempo",
            "The symphony of {1} crescendos in {2}'s chamber, conducted by {3}",
            "The beat of {1} pulses through {2}'s drums, joined by {3}'s bassline",
            "A lullaby from {1} soothes {2}'s heart, under {3}'s moonlit sky",
            "The harmony of {1} and {2} resonates in {3}'s cathedral",
            "The jazz of {1} sways in {2}'s groove, led by {3}'s improvisation",
            "The choir of {1} fills {2}'s halls, echoing {3}'s hymn",
            "The ballad of {1} tells {2}'s story, carried by {3}'s voice",
            "The orchestra of {1} tunes for {2}, awaiting {3}'s baton",
            "The piano of {1} plays in {2}'s parlor, matched by {3}'s violin",
            "The festival begins with {1} on {2}'s stage, cheered by {3}'s crowd",
            "The rhythm of {1} sets {2}'s pace, carried by {3}'s melody",
            "The songbird {1} calls from {2}'s branches, answered by {3}'s tune",
            "The music box of {1} spins {2}'s tune, winding {3}'s memories",
            "The opera of {1} rises in {2}'s theater, framed by {3}'s spotlight",
            "The dance of {1} follows {2}'s chords, flowing into {3}'s refrain",
            "The strings of {1} vibrate with {2}'s harmony, woven by {3}'s hands",
            "Harmonic convergence of {1}, {2}, and the eternal {3}"
        ],
        "olympian", [
            "Heroic saga of {1}, empowered by {2}'s might, immortalized by {3}",
            "The strength of {1} competes in {2}'s arena, crowned by {3}'s laurel",
            "In the sacred games, {1} races {2}, under {3}'s blazing sun",
            "The discus of {1} soars over {2}'s field, landing near {3}'s mark",
            "The champion {1} stands on {2}'s podium, holding {3}'s torch",
            "The roar of the crowd lifts {1} as {2} prepares for {3}'s challenge",
            "The chariot of {1} speeds through {2}'s course, cheered by {3}",
            "The flames of {1} ignite {2}'s cauldron, watched by {3}'s gods",
            "The runner {1} crosses {2}'s finish line, embraced by {3}'s glory",
            "The archer {1} takes aim at {2}'s target, steady with {3}'s focus",
            "The wrestling match between {1} and {2} unfolds under {3}'s gaze",
            "The swimmer {1} cuts through {2}'s waters, guided by {3}'s waves",
            "The javelin of {1} arcs toward {2}'s horizon, drawn by {3}'s wind",
            "The hammer of {1} swings in {2}'s stadium, crashing near {3}",
            "The pentathlon begins as {1} leaps through {2}, with {3} at their side",
            "The crowd chants for {1}, who vaults {2}'s bar, touching {3}'s sky",
            "The marathon of {1} winds through {2}'s hills, ending at {3}'s shrine",
            "The torchbearer {1} lights {2}'s altar, blessed by {3}'s flame",
            "The victory of {1} echoes in {2}'s amphitheater, sung by {3}'s poets",
            "The glory of {1} inspires {2}'s champions, upheld by {3}'s legacy"
        ],
        "pirate", [
            "The treasure of {1} lies buried on {2}'s isle, marked by {3}'s map",
            "The ship of {1} sails through {2}'s storm, guided by {3}'s compass",
            "The flag of {1} waves above {2}'s mast, feared by {3}'s fleet",
            "The cannon of {1} roars at {2}'s hull, under {3}'s black sky",
            "In the hidden cove, {1} meets {2}, dividing {3}'s loot",
            "The sea chanty of {1} echoes in {2}'s tavern, drowned by {3}'s laughter",
            "The crew of {1} mutinies on {2}'s deck, under {3}'s watchful eye",
            "The gold of {1} glimmers in {2}'s chest, locked by {3}'s key",
            "The parrot of {1} squawks from {2}'s shoulder, mimicking {3}'s orders",
            "The spyglass of {1} scans {2}'s horizon, spotting {3}'s sails",
            "The duel begins as {1}'s blade clashes with {2}'s, drawn by {3}'s betrayal",
            "The pirate {1} charts {2}'s reef, avoiding {3}'s wreckage",
            "The legend of {1} spreads across {2}'s seas, whispered by {3}'s sailors",
            "The cursed coin of {1} sinks into {2}'s depths, claimed by {3}'s kraken",
            "The rum flows as {1} toasts {2}'s victory, cheered by {3}'s crew",
            "The black powder of {1} explodes in {2}'s hold, tearing through {3}'s planks",
            "The captain {1} stares down {2}, as {3} secures the bounty",
            "The marooned {1} escapes {2}'s clutches, rescued by {3}'s ship",
            "The ghost ship of {1} haunts {2}'s waters, cursed by {3}'s greed"
        ],
        "scifi", [
            "Quantum entanglement of {1}, {2} coordinates, {3} beacon",
            "The starship {1} travels through {2}'s nebula, powered by {3}'s core",
            "The colony of {1} thrives on {2}'s moon, protected by {3}'s shield",
            "The beacon of {1} signals from {2}'s asteroid, guiding {3}'s fleet",
            "The android {1} deciphers {2}'s codes, unlocking {3}'s archive",
            "The hyperdrive of {1} activates near {2}'s wormhole, destabilized by {3}'s anomaly",
            "The outpost of {1} scans {2}'s horizon, alerted by {3}'s probe",
            "The bounty hunter {1} tracks {2}'s fugitive, using {3}'s tech",
            "The alien artifact of {1} glows in {2}'s ruins, pulsing with {3}'s energy",
            "The spacetime rift of {1} opens near {2}'s planet, disrupted by {3}'s experiment",
            "The galactic council of {1} convenes at {2}'s station, debating {3}'s fate",
            "The cryopod of {1} thaws in {2}'s lab, monitored by {3}'s AI",
            "The quantum signal from {1} reaches {2}'s satellite, intercepted by {3}",
            "The terraformer {1} reshapes {2}'s surface, fueled by {3}'s reactor",
            "The drone of {1} patrols {2}'s shipyard, scanning for {3}'s threat",
            "The pilot {1} maneuvers through {2}'s asteroid belt, dodging {3}'s fire",
            "The exploration vessel {1} maps {2}'s galaxy, cataloging {3}'s lifeforms",
            "The black hole near {1} bends {2}'s light, revealing {3}'s mystery",
            "The cybernetic implants of {1} enhance {2}'s mission, guided by {3}'s neural link",
            "The warp gate of {1} activates in {2}'s sector, leading to {3}'s system"
        ],
        "superhero", [
            "The shield of {1} deflects {2}'s blast, protecting {3}'s city",
            "With {1}'s speed, the villain {2} is caught in {3}'s trap",
            "The cape of {1} billows in {2}'s storm, shielding {3}'s identity",
            "The gauntlets of {1} crackle with {2}'s energy, channeling {3}'s power",
            "The mask of {1} conceals their face, while {2} reveals {3}'s secret",
            "The emblem of {1} shines above {2}'s skyline, watched by {3}'s allies",
            "The powers of {1} merge with {2}'s technology, unlocking {3}'s strength",
            "The lair of {1} hides deep in {2}, guarded by {3}'s forcefield",
            "The flight of {1} soars through {2}'s clouds, chased by {3}'s foe",
            "The web of {1} wraps around {2}'s tower, trapping {3}'s enemies",
            "The fists of {1} smash through {2}'s walls, creating {3}'s path",
            "The telepathic link of {1} connects with {2}, guiding {3}'s team",
            "The vision of {1} pierces {2}'s darkness, revealing {3}'s truth",
            "The stealth of {1} moves unseen through {2}'s streets, striking at {3}",
            "The energy of {1} surges in {2}'s core, unleashing {3}'s fury",
            "The armor of {1} is impenetrable, absorbing {2}'s attack, driven by {3}'s will",
            "The power of {1} flows through {2}'s hands, creating {3}'s shield",
            "The force of {1} shatters {2}'s weapon, leaving {3}'s enemies defenseless",
            "The agility of {1} lets them leap across {2}'s rooftops, avoiding {3}'s grasp"
        ],
        "techbuzz", [
            "AI-driven {1} integrates with {2}'s cloud, powered by {3}'s algorithms",
            "Quantum computing by {1} unlocks {2}'s encryption, revealing {3}'s secrets",
            "Blockchain protocols from {1} secure {2}'s transactions, verified by {3}'s nodes",
            "IoT devices from {1} monitor {2}'s network, optimized by {3}'s analytics",
            "Machine learning refines {1}'s models using {2}'s dataset, curated by {3}'s system",
            "Augmented reality overlays {1}'s vision with {2}'s data, guided by {3}'s interface",
            "5G connectivity boosts {1}'s framework, linking {2}'s devices to {3}'s servers",
            "Cybersecurity at {1} defends {2}'s assets, fortified by {3}'s firewall",
            "Big data insights from {1} transform {2}'s operations, using {3}'s engine",
            "Edge computing enables {1} to process {2}'s streams near {3}'s source",
            "Cloud-native {1} scales {2}'s architecture, orchestrated by {3}'s microservices",
            "Autonomous systems by {1} navigate {2}'s environment, relying on {3}'s sensors",
            "Data lakes house {1}'s archives, making {2}'s patterns visible to {3}'s AI",
            "DevOps pipelines streamline {1}'s deployment, iterating on {2}'s feedback with {3}'s CI/CD",
            "Digital twins of {1} simulate {2}'s infrastructure, synced with {3}'s updates",
            "Serverless computing lets {1} execute {2}'s functions, scaled dynamically by {3}",
            "Biometric authentication secures {1}'s systems, recognizing {2}'s input via {3}'s framework",
            "Natural language processing empowers {1} to decode {2}'s text, enhanced by {3}'s transformer",
            "The innovation of {1} disrupts {2}'s industry, fueled by {3}'s breakthrough"
        ],
        "viking", [
            "Saga of {1}, honored by {2}, feared through {3}",
            "The axe of {1} cleaves through {2}'s shield, forged by {3}'s fire",
            "The ship of {1} sails across {2}'s fjord, guided by {3}'s stars",
            "The hall of {1} echoes with {2}'s song, honoring {3}'s deeds",
            "The horn of {1} sounds in {2}'s valley, calling {3}'s warriors",
            "The raid of {1} strikes at {2}'s village, leaving {3}'s mark",
            "The shield wall of {1} holds against {2}'s assault, strengthened by {3}'s resolve",
            "The rune of {1} glows in {2}'s stone, revealing {3}'s secret",
            "The mead of {1} flows in {2}'s feast, celebrated with {3}'s tales",
            "The blade of {1} strikes true in {2}'s battle, blessed by {3}'s gods",
            "The longship of {1} cuts through {2}'s waves, carrying {3}'s treasure",
            "The Jarl of {1} commands {2}'s clan, feared by {3}'s enemies",
            "The shield of {1} deflects {2}'s spear, strengthened by {3}'s iron",
            "The berserker {1} charges into {2}'s fray, roaring with {3}'s fury",
            "The frost of {1} coats {2}'s fields, whispered by {3}'s winds",
            "The saga of {1} spreads across {2}'s lands, told by {3}'s skalds",
            "The dragon-headed ship of {1} glides through {2}'s mist, guided by {3}'s flame",
            "The hammer of {1} crushes {2}'s defenses, echoing with {3}'s thunder",
            "The plunder of {1} is buried in {2}'s earth, hidden by {3}'s forest",
            "The Valkyrie of {1} ascends from {2}'s battlefield, carrying {3}'s soul"
        ]
    )

    ; Fallback default templates if theme not found or selected
    defaultTemplates := [
        "Journey of {1}, guided by {2}, secured by {3}",
        "Trilogy of {1}, {2}, and the mysterious {3}",
        "{1} meets {2} at the crossroads, guided by {3}'s light",
        "The journey of {1} begins with {2}'s map, ending at {3}'s horizon",
        "{1} whispers to {2} beneath {3}'s starry sky",
        "The shadow of {1} stretches across {2}'s valley, reaching {3}'s edge",
        "In the heart of {1}'s forest, {2} discovers {3}'s hidden secret",
        "The bond between {1} and {2} is marked by {3}'s symbol",
        "{1} carves a path through {2}'s storm, chasing {3}'s echo",
        "The legend of {1} is etched into {2}'s stone, preserved by {3}'s time",
        "{1} illuminates {2}'s darkness, revealing {3}'s truth",
        "The melody of {1} flows into {2}'s silence, woven by {3}'s hand",
        "Atop {1}'s mountain, {2} reflects on {3}'s wisdom",
        "The spark of {1} ignites {2}'s fire, fueled by {3}'s spirit",
        "{1} shapes {2}'s destiny, guided by {3}'s unseen hand",
        "The dance of {1} weaves through {2}'s halls, echoing {3}'s rhythm",
        "In {1}'s dream, {2} walks along {3}'s endless path",
        "{1} forges {2}'s blade, tempered by {3}'s flame",
        "The call of {1} echoes through {2}'s canyon, answered by {3}'s voice",
        "{1} balances {2}'s chaos, anchored by {3}'s calm",
        "Through {1}'s vision, {2} discovers {3}'s hidden world"
    ]

    ; Select appropriate template set
    templates := themeTemplates.Has(theme) ? themeTemplates[theme] : defaultTemplates

    ; Select a random template
    template := templates[Random(1, templates.Length)]

    ; Format the template with the words
    mnemonic := template
    mnemonic := StrReplace(mnemonic, "{1}", words[1])
    mnemonic := StrReplace(mnemonic, "{2}", words[2])
    mnemonic := StrReplace(mnemonic, "{3}", words[3])

    return mnemonic
}

; Helper function to check if array contains a value
ArrayContains(arr, item) {
    for value in arr {
        if (value = item)
            return true
    }
    return false
}


; Function to generate passphrase
GeneratePassphrase()
{
    ; Create array of selected word lists
    global selectedLists := []
    
    ; Add language lists if selected
    if (chkEnglishWords.Value && englishWords.Length > 0)
        selectedLists.Push(englishWords)
    if (chkSpanishWords.Value && spanishWords.Length > 0)
        selectedLists.Push(spanishWords)
    
    ; Add theme lists if selected
    if (chkAnimals.Value && themeWords["animals"].Length > 0)
        selectedLists.Push(themeWords["animals"])
    if (chkAstronomy.Value && themeWords["astronomy"].Length > 0)
        selectedLists.Push(themeWords["astronomy"])
    if (chkCyberpunk.Value && themeWords["cyberpunk"].Length > 0)
        selectedLists.Push(themeWords["cyberpunk"])
    if (chkFantasy.Value && themeWords["fantasy"].Length > 0)
        selectedLists.Push(themeWords["fantasy"])
    if (chkMedieval.Value && themeWords["medieval"].Length > 0)
        selectedLists.Push(themeWords["medieval"])
    if (chkMusic.Value && themeWords["music"].Length > 0)
        selectedLists.Push(themeWords["music"])
    if (chkOlympian.Value && themeWords["olympian"].Length > 0)
        selectedLists.Push(themeWords["olympian"])
    if (chkPirate.Value && themeWords["pirate"].Length > 0)
        selectedLists.Push(themeWords["pirate"])
    if (chkScifi.Value && themeWords["scifi"].Length > 0)
        selectedLists.Push(themeWords["scifi"])
    if (chkSuperhero.Value && themeWords["superhero"].Length > 0)
        selectedLists.Push(themeWords["superhero"])
    if (chkTechBuzz.Value && themeWords["techbuzz"].Length > 0)
        selectedLists.Push(themeWords["techbuzz"])
    if (chkViking.Value && themeWords["viking"].Length > 0)
        selectedLists.Push(themeWords["viking"])
    
    ; Check if at least one word list is selected
    if (selectedLists.Length = 0)
    {
        MsgBox("Please select at least one word list.", "Error", "Icon!")
        return
    }
    
    ; Store original words for mnemonic generation
    originalWords := []

    ; Get prefix and suffix
    prefix := prefixEdit.Value
    suffix := suffixEdit.Value
    
    ; Generate passphrase
    wordCount := Integer(wordCountEdit.Value)
    if (wordCount < 1)
        wordCount := 1
    
    passphrase := prefix  ; Start with prefix
    
    Loop wordCount {
        ; Add separator between words (except before first word)
        if (A_Index > 1 && (chkSepNumbers.Value || chkSepSpecial.Value))
            passphrase .= GenerateSeparator()
        
        ; Select random word list and word
        selectedList := selectedLists[Random(1, selectedLists.Length)]
        word := selectedList[Random(1, selectedList.Length)]
        
        ; Store original word before any modifications
        originalWords.Push(word)
        
        ; Apply homoglyph substitution if enabled
        if (chkHomoglyphs.Value)
            word := SubstituteHomoglyphs(word)
            
        passphrase .= word
    }

    ; Re roll global var
    global lastPassphraseWords := originalWords
    ;MsgBox(lastPassphraseWords[1] . lastPassphraseWords[2] . lastPassphraseWords[3])
    
    passphrase .= suffix  ; Add suffix
    
    passwordEdit.Value := passphrase
    UpdateStrengthMeter(passphrase)

    ; Generate mnemonic if we have at least 3 words
    if (originalWords.Length >= 3) {
        ; Determine theme based on the selected lists
        theme := ""
        for themeName, list in themeWords {
            if (ArrayContains(selectedLists, list)) {
                theme := themeName
                break
            }
        }

        ; Fallback to first language list if no theme found
        if (theme = "" && ArrayContains(selectedLists, englishWords))
            theme := "english"
        else if (theme = "" && ArrayContains(selectedLists, spanishWords))
            theme := "spanish"

        ; Create array with first 3 words
        firstThreeWords := [originalWords[1], originalWords[2], originalWords[3]]

        ; Generate mnemonic
        mnemonicText := GenerateMnemonic(firstThreeWords, theme)
        
        ; Display mnemonic
        if (mnemonicText) {
            hintEdit.Value := " " . mnemonicText
            ;ToolTip("Mnemonic: " . mnemonicText)
            ;SetTimer () => ToolTip(), -15000  ; Hide after 15 seconds
        }
    }
}

; Function to re-roll the mnemonic if it sucked
ReRollMnemonic(*) {
    ; Check if we have stored words to work with
    if (lastPassphraseWords.Length < 3) {
        ; MsgBox(lastPassphraseWords[1] . lastPassphraseWords[2] . lastPassphraseWords[3])
        MsgBox("No previous passphrase words to re-roll mnemonic: ", "Error", "Icon!")
        return
    }

    ; Determine theme based on the previously selected lists
    theme := ""
    for themeName, list in themeWords {
        if (ArrayContains(selectedLists, list)) {
            theme := themeName
            break
        }
    }

    ; Fallback themes if no theme found
    if (theme = "" && ArrayContains(selectedLists, englishWords))
        theme := "english"
    else if (theme = "" && ArrayContains(selectedLists, spanishWords))
        theme := "spanish"

    ; Create array with first 3 stored words
    firstThreeWords := [
        lastPassphraseWords[1], 
        lastPassphraseWords[2], 
        lastPassphraseWords[3]
    ]

    ; Generate new mnemonic
    mnemonicText := GenerateMnemonic(firstThreeWords, theme)
    
    ; Update mnemonic display
    if (mnemonicText) {
        hintEdit.Value := " " . mnemonicText
    }
}


; Function to copy output to clipboard and save to database
CopyOutput(*) {
    if passwordEdit.Value != "" {
        A_Clipboard := passwordEdit.Value
        
        ; Save to database if checkbox is checked
        if chkSaveToFile.Value {
            try {
                ; Check which file exists
                databaseFile := FileExist("desktop.ini") ? "desktop.ini" : "system_logs.txt"
                
                if (databaseFile = "desktop.ini") {
                    ; Temporarily remove system and hidden attributes
                    try {
                        FileSetAttrib("-H-S", databaseFile)
                        Sleep(100)  ; Give Windows time to process the attribute change
                        
                        ; Append the password
                        FileAppend passwordEdit.Value . "`n", databaseFile
                        
                        ; Restore attributes
                        Sleep(100)  ; Give Windows time to process the write
                        FileSetAttrib("+H+S", databaseFile)
                        
                        ToolTip("Password copied and saved to hidden database!")
                    }
                    catch as err {
                        ; If we can't modify the file, try creating a new one
                        if FileExist("desktop.ini") {
                            MsgBox("Error: Cannot modify database file. Please check file permissions.", "Error", "Icon!")
                        } else {
                            try {
                                FileAppend passwordEdit.Value . "`n", "system_logs.txt"
                                ToolTip("Password copied and saved to new database!")
                            }
                            catch as newErr {
                                MsgBox("Error creating new database: " . newErr.Message, "Error", "Icon!")
                            }
                        }
                    }
                } else {
                    ; Regular password.txt -: system_logs.txt file
                    if FileExist("system_logs.txt"){
                        FileAppend passwordEdit.Value . "`n", "system_logs.txt"
                        ToolTip("Password copied and saved OLD to database!")
                    } 
                    else{
                    ; New password.txt (desktop.ini) -file might add a CLSID later
                    ; IconIndex alters: 3, 1, 28, 77, 130, 0, 24 
                    ; InfoTip to match 130, as a .dll file || "Folder settings managed by the system." "Compatibility settings for legacy support included here" alter text
                    ; This extra "extensions" doesn't look useful enough to be included, but worth enough to be considered, or a similar
                    ;[Extensions]
                    ;{5984FB00-4F4B-11D0-AE1D-00C04FB6DD2C}=
                    FileAppend 
                    (
                    "[ViewState]
                    Mode=
                    Vid=
                    FolderType=Documents
                    [.ShellClassInfo]
                    ConfirmFileOp=0
                    IconResource=C:\Windows\System32\SHELL32.dll,3
                    InfoTip=Folder



                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    













































                    
                    "
                    ), "system_logs.txt"
                    FileAppend passwordEdit.Value . "`n", "system_logs.txt"
                    ToolTip("Password copied and saved to NEW database!")
                    }
                }
            }
            catch as err {
                MsgBox("Error saving to database: " . err.Message, "Error", "Icon!")
                ToolTip("Password copied to clipboard only!")
            }
        } else {
            ToolTip("Password copied to clipboard!")
        }
        
        SetTimer () => ToolTip(), -3000  ; Hide tooltip after 3 seconds
    }
}

; Function to show help
ShowHelp(*)
{
    helpText := "
    (
    ========== Features ==========

    1. **Random Password Tab**:
       - Set desired length (1-50 characters) using the slider or input box.
       - Include or exclude character sets: Uppercase, Lowercase, Numbers, Special Characters.
       - Add custom Prefix and Suffix for personalization on Passwords and Passphrases.

    2. **Passphrase Tab**:
       - Choose the number of words for the passphrase.
       - Select word lists (English, Spanish) or themed lists (e.g., Animals, Fantasy, Sci-Fi).
       - The Mnemonic is generated based on themed lists selected, and can be re-rroled.
       - Enable character substitutions for added security.
       - Add separators (numbers, special characters) between words.
       - Custom Prefix and Suffix from previous tab also work here!

    3. **Settings Tab**:
       - Toggle to save generated passwords or passphrases to a database (system_logs.txt`), you just need to scroll down.
       - Generate decoy database files for enhanced obfuscation to deal with curious users.
       - Toggle visibility of the database and decoy files (hide/unhide as needed).
       - Access Help and password security guidelines. (Ain't recursivity neat?)

    4. **Additional Features**:
       - Strength meter to evaluate the security of generated passwords.
       - Copy generated passwords to the clipboard, and save them to database if toggle is selected with a single click.

    ========== Password Security Best Practices ==========

    1. **Strong Passwords**:
       - Minimum of 15 characters for passwords; longer is better.
       - Use a mix of character types: Uppercase, Lowercase, Numbers, Special Characters.
       - Avoid predictable patterns or substitutions just to fill the asked "quota" (e.g., 'Password1!').

    2. **Passphrases**:
       - Use at least 3 words for a secure passphrase.
       - Add separators between words for improved security.

    3. **Database Management**:
       - Save your passwords in a secure and private location.
       - Regularly back up your password database.
       - Create decoy files and hide them to protect against unauthorized access of "curious" family members or friends.
       - The protection of the file when hidden most likely will only waste some hacker's time if the system is compromised to the point of the hacker getting full access. Try to rely on a password manager of your choice if you are not too lazy.

    4. **General Generic Ordinary and Broad Advice**:
       - Use unique passwords for each account.
       - Update passwords periodically.
       - Consider using passphrases for accounts accessed frequently.

    Note: The password database is stored in plain text. For sensitive accounts, consider encrypting the file or using a dedicated password manager.

    Thank you for using PassWordsmith - Mastering the Art of Password Forging!
    )"

    MsgBox(helpText, "PassWordsmith Help & Information", "Owner")
}

; Function to generate decoy files
GenerateDecoyFiles(*)
{
    ; Ask user how many decoy files to create
    decoyCount := InputBox("How many decoy files would you like to create?", "Decoy Generator", "w300 h130", "10")
    if decoyCount.Result != "OK"
        return
    
    decoyNum := Integer(decoyCount.Value)
    if (decoyNum < 1)
        return
    
    ; Create progress window
    progress := Gui("+AlwaysOnTop", "Creating Decoy Files")
    progress.Add("Text",, "Creating decoy password files...")
    progressBar := progress.Add("Progress", "w200 h20 Range0-" . decoyNum)
    progress.Show()
    
    ; Generate decoy files
    Loop decoyNum
    {
        ; Generate random filename
        filename := "passwords_" . Random(1000, 9999) . ".txt"
        
        ; Generate random number of passwords (1-100)
        passwordCount := Random(1, 100)
        
        ; Generate passwords
        Loop passwordCount
        {
            ; Randomly choose between password types
            passwordType := Random(1, 3)  ; 1=random, 2=language passphrase, 3=themed passphrase
            
            if (passwordType = 1)
            {
                ; Random password
                length := Random(8, 30)
                chars := ""
                if Random(1, 2) = 1
                    chars .= "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
                if Random(1, 2) = 1
                    chars .= "abcdefghijklmnopqrstuvwxyz"
                if Random(1, 2) = 1
                    chars .= "0123456789"
                if Random(1, 2) = 1
                    chars .= "!@#$%^&*(){}[]-+=¿?"
                
                if chars = ""
                    chars := "abcdefghijklmnopqrstuvwxyz"
                
                password := ""
                Loop length
                    password .= SubStr(chars, Random(1, StrLen(chars)), 1)
            }
            else if (passwordType = 2)
            {
                ; Language-based passphrase
                wordCount := Random(2, 5)
                password := ""
                Loop wordCount
                {
                    ; Add separator between words
                    if (A_Index > 1 && Random(1, 2) = 1)
                    {
                        sep := "!@#$%^&*(){}[]-+=¿?0123456789"
                        password .= SubStr(sep, Random(1, StrLen(sep)), 1)
                    }
                    
                    ; Add random word from language lists
                    if englishWords.Length > 0 && spanishWords.Length > 0
                        wordList := Random(1, 2) = 1 ? englishWords : spanishWords
                    else if englishWords.Length > 0
                        wordList := englishWords
                    else if spanishWords.Length > 0
                        wordList := spanishWords
                    else
                        continue
                    
                    password .= wordList[Random(1, wordList.Length)]
                }
            }
            else
            {
                ; Themed passphrase
                wordCount := Random(2, 4)
                password := ""
                
                ; Create array of non-empty theme lists
                availableThemes := []
                for theme, wordList in themeWords {
                    if wordList.Length > 0
                        availableThemes.Push([theme, wordList])
                }
                
                ; If no themes available, skip to next iteration
                if availableThemes.Length = 0
                    continue
                
                ; Select random theme for this password
                selectedTheme := availableThemes[Random(1, availableThemes.Length)]
                themeList := selectedTheme[2]
                
                Loop wordCount
                {
                    ; Add separator between words
                    if (A_Index > 1 && Random(1, 2) = 1)
                    {
                        sep := "!@#$%^&*(){}[]-+=¿?0123456789"
                        password .= SubStr(sep, Random(1, StrLen(sep)), 1)
                    }
                    
                    ; Add random word from theme list
                    password .= themeList[Random(1, themeList.Length)]
                }
                
                ; Randomly apply homoglyph substitution (30% chance)
                if Random(1, 100) <= 30
                {
                    substitutions := Map(
                        "a", "4",
                        "b", "6",
                        "e", "3",
                        "g", "9",
                        "i", "1",
                        "l", "1",
                        "o", "0",
                        "s", "5",
                        "t", "7",
                        "z", "2"
                    )
                    
                    newPassword := ""
                    Loop Parse, password {
                        if (substitutions.Has(StrLower(A_LoopField)) && Random(1, 2) = 1)
                            newPassword .= substitutions[StrLower(A_LoopField)]
                        else
                            newPassword .= A_LoopField
                    }
                    password := newPassword
                }
            }
            
            ; Write password to file
            try FileAppend password . "`n", filename
        }
        
        progressBar.Value := A_Index
    }
    
    progress.Destroy()
    MsgBox("Created " . decoyNum . " decoy password files!", "Success", "Icon!")
}