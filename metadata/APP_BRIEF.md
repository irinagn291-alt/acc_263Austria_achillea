<!-- gf-brief source=3a615abf2c5b313e85818d974925e2ba9e544b876dc66e01c5cc8dadebfe6d4a written=2026-09-26T01:28:55+03:00 -->
# Achillea
## What it is
Achillea is a dark, portrait name-picker for people who need one clear choice from a short list. You type names, optionally set chances or turn on even chance, lock the list, then Draw picks one name and saves it in History on this device.

## Launch and onboarding
1. Cold launch shows a full-screen splash image briefly (no text), then either onboarding or the main list.
2. On first launch (and after “Reset all data”), a four-page onboarding cover appears. Dark theme throughout.
3. Page 1: “One honest pick from names you type.” / “Not a room spinner. Not a score sheet.” Top-right “Skip” (pages 1–3 only). Bottom “Continue”. Page indicator is announced as “Page 1 of 4” (and so on).
4. Page 2: “Lock the list. Then Draw.” / “Once locked, names and chances stay put.” “Skip” / “Continue”.
5. Page 3: “Filed picks stay on this device.” / “History keeps each pick. Undo last pick removes the newest one.” “Skip” / “Continue”.
6. Page 4: “Even chance treats two names the same.” / “Chances stay even. Draw can run without a lock.” No “Skip”. Bottom “Begin”.
7. “Skip” or “Begin” dismisses onboarding and opens the main list. Later launches skip onboarding unless you re-run it from Settings.
8. At launch the system may also show the standard notifications permission prompt.

## Screens
### Main list (“Achillea”)
No tabs. Chrome: clock control (VoiceOver “Open History”), title “Achillea”, gear control (VoiceOver “Open Settings”).

Headline always “Draw picks one name.” Supporting line depends on state:
- Idle: “Draw chooses from the names below and saves that pick in History.”
- Even chance on: “Both names share the same chance. Draw chooses one and saves it in History.”
- Locked: “The names are locked. Draw chooses one and saves it in History.”
- After a pick: “That pick is in History. Start a new list for another.”

Status rail (not tappable): “Names” (count), “Chance” (sum, or “Even”), “Status” (“Ready”, “Locked”, or “Saved”).

**Empty list (no names yet)**  
“Type two names.” / “Draw will pick one of them and save it in History.” Fields “First name”, “Second name”. Button “Save names” (disabled until both fields have text). Keyboard “Done” dismisses the keyboard.

**Populated list**  
Editable name rows with placeholder “Name”, optional “Chance” field (hidden when “Even chance” is on), and remove control (VoiceOver “Remove name”; hidden once locked or after a pick).  
Add row: “Add a name”, optional “Chance” (default draft “1”), “Add” (disabled until the name field has text).  
Toggle “Even chance” with hint “Both names get the same chance. Draw can run now.” (disabled when not Ready).  
Primary actions:
- “Lock names” when Ready, at least two names, and even chance is off (disabled until those conditions).
- “Draw” when the list is Locked, or when even chance is on with exactly two names (disabled until then).
- After a pick: banner “Picked {name}”, status “Saved”, and “New list” (keeps names, clears the lock/pick state so you can lock or draw again).

On wider layout (e.g. iPad), a side panel also shows fold title (“Ready” / “Locked” / “Saved”), hints (“Lock the names, then Draw can pick.” / “Tap Draw to choose one name from this list.” / “That pick is saved. Start a new list when you want another.”), “Last pick” (name and time, or “Draw will write the next name here.”), and “Recent picks” (up to three older picks). Tapping Last pick or a recent row opens History.

Errors show as a notice with “Retry” (for example “Could not save the list. Try again.”, “Restored the last good list.”, “The saved list could not be read. Starting empty.”, or fold messages such as “Lock the names first, then Draw.”).

### History
Sheet titled “History”. Close (x, VoiceOver “Close”).

Empty: “No picks yet.” / “Draw a name, then read it here.” / “Back to the list”.  
Error with empty history: “History could not load.” plus the fault line and “Retry”.  
Populated: picks grouped by medium-style day title; each row shows the name and a short local time. Footer “Undo last pick” opens confirm “Undo the last pick?” / “The newest pick leaves History. Names stay.” with “Undo last pick” and “Cancel”.

### Settings
Sheet titled “Settings”. Close (x, VoiceOver “Close”).

If nothing is stored: “Nothing stored yet.” / “Add two names on the list, then come back.” / “Back to the list”.  
Always: “How Draw picks” / “Draw chooses one name from the list you typed. The same names and chances give the same pick again.” plus counts labeled “Names” and “History”.  
“Contact” with subtitle “achillea-ask.pro/contact-us” (opens the support page).  
“How Draw works” opens the guide sheet.  
“Re-run onboarding” returns to the four-page cover.  
“Reset all data” confirms with “Reset all data?” / “This removes names, locks, and saved picks on this device.” / “Reset all data” / “Cancel”; after reset, onboarding shows again.

### How Draw works
Sheet titled “How Draw works”.  
“Lock the list, then pick.”  
“Lock names so they cannot change. Draw then picks one name by chance and saves it in History. Draw does nothing until the list is locked, unless even chance is on.”  
“Even chance gives both names the same chance, so Draw can run without locking.”  
Current status card repeats fold word and job line.  
“Back to the list” and Close dismiss the sheet.

## Features
- Type two or more names and save them on a list
- Set a numeric “Chance” per name (or hide chances with “Even chance”)
- “Even chance” for exactly two names so Draw can run without locking
- “Lock names” to freeze the list
- “Draw” to choose one name by chance and save it in History
- “New list” after a pick to reuse the same names
- History of filed picks by day, with “Undo last pick”
- Settings: how Draw picks, Contact, How Draw works, re-run onboarding, reset all data
- Onboarding that can be skipped or re-run
- Data kept on this device (per onboarding and reset copy)

## Behaviours that can look like bugs
- “Save names” stays disabled until “First name” and “Second name” both have text.
- “Add” stays disabled until “Add a name” has text.
- “Lock names” stays disabled with fewer than two names, or while “Even chance” is on (“Even chance is on. Draw from here.” if you try the other path).
- “Draw” stays disabled until the list is Locked, unless “Even chance” is on with exactly two names (“Lock the names first, then Draw.”).
- With “Even chance” on, Chance fields disappear and stay even; turning it on requires exactly two names (“Even chance needs two names.”).
- After lock or after a pick, name editing and remove are frozen (“The names are already locked.” / “This list already saved a pick.”).
- After a pick, only “New list” advances the flow for another draw; History still holds the pick.
- Empty History (“No picks yet.”) until the first successful Draw; use “Back to the list” or Close.
- Empty Settings invite (“Nothing stored yet.”) until names or picks exist; “Back to the list” dismisses.
- “Undo last pick” is unavailable when there is nothing to undo (“There is no pick to undo.”).
- Chance must be a number above zero when locking/editing (“Each chance must be a number above zero.”).
- Reset or Skip/Begin loops back into onboarding or the empty “Type two names.” state on purpose.

## Starter content and resume
On a physical device: None. The list and History start empty until you type names and Draw.

On Simulator only, a one-time demo may plant names “Rowan” and “Sable” (even chance on) plus several prior History picks (including “Tansy”).

Unfinished work resumes: names, lock state, even-chance setting, onboarding completion, and History persist across launches. After a filed pick, use “New list” to continue with the same names; “Undo last pick” removes the newest History entry and returns the list to Ready.

## Permissions
- Notifications: system permission is requested at cold launch (standard iOS notifications alert). No custom usage-description string in the app’s Info settings for notifications.
- Camera: usage description present — “This app does not use the camera.” — but the native UI never asks for camera access and never uses the camera.

## Absent
Login or accounts; in-app purchase; ads; analytics; account deletion flow; App Tracking Transparency prompt.

User-generated content is present (typed names and saved picks). Local “Reset all data” clears this device; there is no cloud account to delete.

## Data and support
Names, locks, and History stay on this device (stated in onboarding and in the reset confirmation).

On-screen support: Settings → “Contact” / “achillea-ask.pro/contact-us” (opens that support page).

## Scanning and health
None.

## Platform
No region lock; dates, times, and numbers follow the device locale. Portrait only on iPhone and iPad. Dark appearance. Full-screen. Minimum iOS 17.0.

## Category
Lifestyle
