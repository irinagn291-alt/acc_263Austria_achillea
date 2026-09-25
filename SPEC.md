# Achillea — Build Specification

> Portfolio app 124, batch pending. This document is the complete brief for
> building this application. Read all of it before writing any code. Anything
> not specified here is your decision, but must stay consistent with section 3.

**One-line positioning:** Draw one pick from names you typed.

| Field | Value |
| --- | --- |
| Product name | Achillea |
| Bundle identifier | `com.achillea.ask` |
| Domain | https://achillea-ask.pro |
| Contact URL | https://achillea-ask.pro/contact-us |
| Deployment target | iOS 17.0 |
| Swift version | 6.2, strict concurrency `complete` |
| Devices | iPhone and iPad, portrait |
| Interface style | Dark |
| Asset prefix | `ach_` |
| User-Agent | `Achillea/1.0 (iOS; +https://achillea-ask.pro)` |

---

## 1. Non-negotiable constraints

1. **No CocoaPods.** Dependencies come from Swift Package Manager, a local
   in-repo package, a vendored source folder, or nothing at all — per section 3.
2. **No shared code with other portfolio apps.** Business rules are re-implemented
   here under this app's own type names.
3. **All code, identifiers, comments, UI copy and the README are in English.**
4. **No launch gate, no WebView shell, no remote configuration, no analytics.**
   Guideline 4.2 (Minimum Functionality): this is a native SwiftUI product, not
   a web browsing experience. WKWebView / SFSafariViewController as UI is a
   reject. Push notifications, Core Location, and sharing do not make a
   browser or a thin catalog into an App Store app.
5. **Guideline 5.1.1 (Privacy):** never direct the user to grant camera access.
   A pre-permission screen may exist; the proceed button is **Continue** or
   **Next**, never "Allow camera", "Enable camera", "Grant camera", or a bare
   Allow/Enable that triggers `requestAccess`. The system alert is the only Allow.
6. **No CI files.** No `bitrise.yml`, no `Scripts/`, no `metadata/` folder.
7. **Assets are AI-generated.** No stock photography. SF Symbols may support
   small affordances but must never be the primary iconography.
8. **The app must build clean** with
   `xcodegen generate && xcodebuild -scheme Achillea -destination 'generic/platform=iOS' build`.
9. **Nothing may echo another app in this batch** in naming, layout or visuals.
10. **This is not a calorie meal-slot tracker** unless family is `food_tracker`.
   Do not invent food logging to fill the brief.

---

## 2. Product core

The product is offline-first. No account, no sign-in, no ads, no in-app purchase,
no analytics SDK, no remote config. All user data stays on the device.

A stuck chooser taps Draw after pledging the name list so one option files as the pick.

### 2.1 User flow

1. Tap Draw on the seeded ask so one pledged name files as the pick.
2. Open History as a sheet and read the filed pick.
3. Start a new ask, type two or more names, and set optional stalk counts.
4. Switch to dispute mode so two names sit at even mass and the stalk rails stay hidden.
5. Tap Gage to freeze the list, then tap Draw to file.
6. Open Settings to read how the seeded generator works.

### 2.2 Essential behaviour

- Typed names, at least two, optional stalk mass of 0.01 or more
- Seeded massed chance over pledged names
- Dispute path: two names, even mass, rails hidden, Gage skipped
- History of filed picks only, local, no account
- Retract peels the newest Slip
- Numeric rail shows name count, stalk sum, and gage state

---

## 3. Uniqueness assignment for Achillea

| Axis | Assigned value |
| --- | --- |
| Architecture | **Milfoil ADT fold (Idle | Gaged | Filed); the ask is a fold over Names; Gage writes a GageMark and freezes the Names and folds Idle to Gaged; Draw writes a Slip by massed chance and folds Gaged to Filed; Draw on Idle is refused; a second Gage while Gaged is refused; Gage samples an Ask with at least two Names; empty ask writes Bare; dispute path writes two Names at even mass and skips Gage so Draw from Idle may file** |
| UI approach | **UIKit UITableView NIB registered cells · spritekit-accent** |
| Naming convention | **Yarrow / milfoil lexicon** |
| File organization | **By milfoil role (Ask, Name, Stalk, GageMark, Slip, DecisionRecord)** |
| Dependency strategy | **None** |
| Design direction | **fantasy · numeric-rail · soft** |
| Typography | **SF Pro** |
| Navigation pattern | **Stalk-locked chrome (the milfoil rail never leaves; History and Settings arrive as sheets)** |
| AI art style | **Neon outline glowing line art · typographic** |
| Functional twist | **Gage-then-draw (the name list freezes before the pick; Draw on Idle is refused)** |
| Persistence | **UserDefaults+Codable** |
| Screen composition | see 3.6 |

### 3.0 Product concept

This is the product the contracts below are assigned to. Do not substitute another.

**Family** — random_picker

**Core** — A stuck chooser taps Draw after pledging the name list so one option files as the pick.

**Audience** — People who need one honest pick from typed names, not a room spinner and not a scored matrix.

**User flow**

1. Tap Draw on the seeded ask so one pledged name files as the pick.
2. Open History as a sheet and read the filed pick.
3. Start a new ask, type two or more names, and set optional stalk counts.
4. Switch to dispute mode so two names sit at even mass and the stalk rails stay hidden.
5. Tap Gage to freeze the list, then tap Draw to file.
6. Open Settings to read how the seeded generator works.

**Essential features**

- Typed names, at least two, optional stalk mass of 0.01 or more
- Seeded massed chance over pledged names
- Dispute path: two names, even mass, rails hidden, Gage skipped
- History of filed picks only, local, no account
- Retract peels the newest Slip
- Numeric rail shows name count, stalk sum, and gage state

**Twist** — Gage-then-draw. Ask keeps the name table. Gage freezes every Name and writes a GageMark. Draw then runs a seeded massed chance over those Names, each mass 0.01 or more, and writes a Slip that files as the pick. Draw before Gage does nothing. A later Gage while Gaged does nothing. Dispute path writes two Names at even mass, keeps the stalk rails out, and skips Gage so the opening Draw can file. Retract peels the newest Slip. Gage on a crate under two Names writes Bare. Launch already pledges two Names so the opening Draw can file. Home verb: gage-then-draw, not a post-pick reject and not a room wheel. History lists filed Slips. Settings names the seeded generator. No criteria grid.

**Why this is not a repeat** — Klerion draws first and then accepts or rejects the nominee with a one-strike chip. This product reverses that order: the chooser pledges the field first, the list cannot change, and only then does Draw file a pick. There is no post-pick reject, no party wheel, and no criteria matrix. Home is the Ask table with a numeric stalk rail, not a three-tab stamp and not an urn pot. The same honest seeded chance remains, but the job on home is gage-then-draw.

### 3.0a Craft from the shipped portfolio

Full craft is in KNOWLEDGE.md. Follow it. Do not copy type names or layouts.
- Home: No tabs. Ask → options → optional weights → reveal.
- Invariant: Weighted roulette, weight ≥ 0.01, seeded RNG. Argument mode = forced 50/50, sliders skipped. Need ≥ 2 non-blank options.
- Never: Not Spinmob. Not Tradeoff.
- Desk `spoke_length`: L=√(r1²+r2²+off²−2 r1 r2 cos(2π·cross/n))−hole/2. Polar 32-spoke map is mandatory.
- Taste DNA is section 7.6. Do not invent a second look.
- A TabView with exactly three tabs is the factory stamp — use two or four-to-five destinations, or a different chrome. `-ReviewScreen today|log|goals` are launch keys, not tabs.
- Mini-ref `Polinka`: steal Typed options, one honest pick, haptics, history, empty feed. Never WKWebView contact. Do not turn the pick into a gambling board. New types and layout — do not reskin.

### 3.1 Architecture contract

The Ask is a closed algebraic fold over Names with cases Idle, Gaged, and Filed, and a fourth case is a defect. Gage samples an Ask with at least two non-blank Names, writes a GageMark, freezes every Name and its Stalk mass, and folds Idle to Gaged. Gage on a crate under two Names writes Bare, and a second Gage while Gaged is refused. Draw writes a Slip by seeded massed chance, each mass at least 0.01, files that Slip as a DecisionRecord, and folds Gaged to Filed. Draw on Idle is refused except on the dispute path, which writes two Names at even mass, hides the stalk rails, skips Gage, and lets Draw file from Idle. Retract peels the newest Slip. One observable AskStore pattern-matches the fold. Views call gageAsk, drawSlip, and peelSlip and never keep a parallel bool. Unit tests prove massed chance with weight at least 0.01, a seeded generator, at least two non-blank Names, the dispute fifty-fifty clamp with rails skipped, Draw-on-Idle refuse, second-Gage refuse, Bare, and Retract of the newest Slip.

Put a short comment block at the top of each principal type stating the role it
plays in this architecture. The README must justify the pattern for this product.

### 3.2 UI contract

SwiftUI owns Ask chrome, History, Settings, and onboarding. The pledged Name table is a UIKit UITableView with NIB-registered cells hosted by one UIViewRepresentable sitting under the numeric rail. That table is the mechanic, not a records tab. Confine SpriteKit to one glowing milfoil accent on the numeric rail that shows name count, stalk sum, and gage state. Gate travel with accessibilityReduceMotion so Reduce Motion fades the group at once. Every other surface is stock SwiftUI List, Form, Button, TextField, Toggle, and sheet. No TabView. No second SpriteKit surface. Empty Ask and onboarding are full pages with frame maxHeight infinity and a bottom full-width CTA. Chrome lives inside Button labels with contentShape, min 44pt. Primary Gage and Draw use one ButtonStyle with default, pressed, disabled, and loading. Retract is not the live-verb accent. One haptic on a successful Draw that files a Slip, none on presenting a sheet. Colour is never the only Idle versus Gaged versus Filed signal. The ui axis string is never a section title.

### 3.3 Naming contract

Convention: Yarrow / milfoil lexicon.

Examples to follow: `GageMark`, `fileSlip()`, `DecisionRecord`, `Name`

### 3.4 Dependency contract

None. Zero SPM packages. project.yml has no packages key. No CocoaPods, no Alamofire, no URLSession catalog client. Foundation, SwiftUI, UIKit, and system SpriteKit only. The leftover AVCaptureMetadataOutput and cgi search pl axes stay unused: do not import AVFoundation for capture, do not request camera permission, and do not call cgi/search.pl or Open Food Facts.

### 3.5 Navigation contract

Stalk-locked chrome. Ask is the root and the milfoil numeric rail never leaves. Gage and Draw fuse on Ask. There is no TabView and no pushed detail. History and Settings arrive as sheets from the rail chrome. Close dismisses a sheet. One haptic on a successful Draw, none on presenting a sheet. After onboarding, read ProcessInfo.processInfo.arguments once: ReviewScreen today stays on Ask, log presents History, goals presents Settings. Contact URL https://achillea-ask.pro/contact-us lives on Settings.

### 3.6 Screen composition contract

Ask-root fused pick (Ask holds the name table and stalk rail; History and Settings are sheets; gage and draw stay on Ask)

Ask-root fused pick. Physical screens: Ask, History, Settings. Ask is the only full screen (ReviewScreen today): name table, numeric rail with name count, stalk sum, and gage state, Gage, Draw, Retract, and the dispute toggle. History is a sheet of filed Slips keyed by Int YYYYMMDD (ReviewScreen log). Settings is a sheet that names the seeded generator, holds the contact URL, re-run onboarding, and resetAllData (ReviewScreen goals). Onboarding is a one-shot cover that writes defaults. Empty Ask is a full page: Type two names. The ask will draw. Seeded Ask is already a dispute of two pledged Names so Draw can file. No tab bar. No Today, Scan, Search, or Goals screens.

Section 5 lists the logical functions that must exist. This section decides how
they are grouped into actual screens. Where the two disagree, this section wins.

A TabView with exactly three tabs is the factory stamp — use two or four-to-five destinations, or a different chrome. `-ReviewScreen today|log|goals` are launch keys, not tabs.

---

## 4. Target file organization

Scheme: **By milfoil role (Ask, Name, Stalk, GageMark, Slip, DecisionRecord)**

```
Achillea/
  Ask/
Name/
Stalk/
GageMark/
Slip/
DecisionRecord/
  Assets.xcassets/
```

Adapt the leaf files to the architecture, but the top-level shape is fixed. Do
not create a `Utils/` or `Helpers/` dumping ground.

---

## 5. Screens

Build the screens named in section 3.6. The labels below are logical;
actual type names follow this app's naming convention.

### 5.1 Onboarding
Three to four pages. Explains the product, writes initial settings, sets a
completion flag. Skip still writes sensible defaults. Re-runnable from Settings.

### 5.2 Ask
A first-class screen for **Ask**. Must render empty, populated and error states.

### 5.3 History
A first-class screen for **History**. Must render empty, populated and error states.

### 5.4 Settings
A first-class screen for **Settings**. Must render empty, populated and error states.

### 5.5 Settings
Holds: re-run onboarding, reset all data (confirmed), and the contact link to
the domain contact-us URL.

### 5.6 Twist screen
See section 12. The twist needs at least one screen of its own plus a surface on the home screen.


---

## 6. Domain model

Minimum entities, named per this app's convention:

- **DecisionRecord** — named per this app's convention.
- Plus whatever the twist in section 12 requires.


---

## 7. Design system

Direction: **fantasy · numeric-rail · soft**

### 7.1 Palette

| Token | Hex | Use |
| --- | --- | --- |
| `background` | `#1B161D` | Screen background |
| `surface` | `#261F28` | Cards, rows, sheets |
| `ink` | `#F1EDF2` | Primary text and icons |
| `accent` | `#BB64D8` | Primary action, key figure, progress fill |
| `muted` | `#A296A7` | Secondary text, dividers, disabled |

Define these as named colours in `Assets.xcassets` and reach them through one
typed accessor. Never hard-code a hex string anywhere else.

### 7.2 Typography

Family: **SF Pro**

SF Pro via Font.system is the UI face. The assigned type move is serif display once: one system serif hit (New York or Font.system with design serif) for the Ask title or the live rail figure, then SF Pro for every other line. Agency feel: huge short display, one or two lines, never more than four, never above 34pt. Body about 17pt. Rail figures are SF Pro tabular through NumberFormatter: name count, stalk sum, gage state. At most six named steps behind one accessor: display, title, headline, body, caption, micro. Weights carry hierarchy. No bundled custom face, no second family beyond that one serif hit, no fixedSize, never below 12pt. Dynamic Type. At AX5 the serif display may drop a step so it never clips. @ScaledMetric for any custom size. Day edges use Calendar.current.startOfDay then fold to Int YYYYMMDD.

Define a type scale of at most six steps behind one accessor and use only those
steps. Text stays legible at the largest Dynamic Type size.

### 7.3 Layout

- One base spacing unit (4 or 8 pt); only multiples of it.
- Corner radius and elevation are fixed by section 7.4, not chosen per screen.
- Every interactive element is at least 44x44 pt.

### 7.4 Component contract

Corner radius: **20pt** for cards, sheets and primary surfaces; **12pt** for chips, badges and small controls. Reach both through one accessor. Never a bare literal number, and never zero — a hard edge is not this app's design direction.

Elevation: **hairline+fill** — a 1pt hairline border plus a flat fill tint, reused everywhere a surface sits above another.

Primary control: **soft card** — primary actions live inside a rounded card using the radius below, not a flat row with no fill.

This is arithmetic, not a suggestion: every card, sheet, chip and button in this app uses these two radii and this elevation style. Do not introduce a second radius or a second elevation style.

### 7.5 Custom rendering scope

This app's `ui` axis is **UIKit UITableView NIB registered cells · spritekit-accent**.

If that approach uses anything beyond stock SwiftUI/UIKit controls — `Canvas`, `CALayer`, Metal, SceneKit, SpriteKit, RealityKit, a hand-drawn `UIViewRepresentable`, or any other pixel-level custom rendering — confine it to exactly one hero surface on one screen (the mechanic's home view, or the one screen this axis exists to showcase). Every other screen — every list, every settings screen, every sheet, every secondary surface — is built from stock components: `List`, `Form`, `NavigationStack`, `TabView`, `Button`, `.sheet`, native `Text`/`Image`. A second custom-rendered surface elsewhere in the app is a defect, not a stylistic choice.

If **UIKit UITableView NIB registered cells · spritekit-accent** is already fully native (no custom drawing layer), this section is satisfied automatically — there is nothing to confine.

The `ui` axis value is an implementation choice. It must never appear as a user-visible section title or label.

### 7.6 Taste DNA

Aesthetic: **agency** (High-end agency: huge type, air, one accent, hairline depth.)

Reference system: **fantasy** — steal rhythm and restraint, not their colours or logos.

Mood: **Game-inspired fantasy aesthetic with bold, premium visuals, rich color palettes, and immersive thematic elements.**.

Home rhythm (`numeric-rail`, comfortable): A row of live figures, then the log. Numbers are the chrome.

High-end agency: huge type, air, one accent, hairline depth. Layout `numeric-rail`, density comfortable. Kit 20/12, hairline+fill, soft card. Palette recipe `soft`. Grouped reveals step 40-60ms, cap 360ms total. Last item must not arrive late. Reduce Motion: the group appears at once. Reduce Motion: fade only. Do not invent a second radius or a second accent.

Type move: Serif display once; body stays the UI face. Reference type feel: agency.

Motion (`stagger`): Grouped reveals step 40-60ms, cap 360ms total. Last item must not arrive late. Reduce Motion: the group appears at once.

Voice (`warm`): Human and brief. Empty states invite. Errors stay calm and useful.

Anti-slop from KNOWLEDGE.md applies. Taste never overrides contrast, 44pt hits, VoiceOver labels, or Reduce Motion.

---

## 8. UI and UX quality bar

Every item here is a defect if it is missing. Do not treat this as advice.

**Layout**

- Respect safe areas on every screen. Nothing sits under the notch, the Dynamic
  Island or the home indicator.
- The app is portrait-only on iPhone. Lock it in the Info settings and do not
  write rotation-dependent layout.
- No layout shift when asynchronous data arrives. Reserve the final size up
  front, or use a redacted placeholder of the same dimensions.
- Long product names must truncate gracefully, never push a number off screen.
  Numbers win; names truncate.
- Sibling cards, images and titles never overlap. Each cell owns its frame;
  `scaledToFill` is clipped to that cell. A chopped headline or two canvases
  in one slot is a defect, not a collage.
- Minimum tap target 44x44 pt for every interactive element, including small
  icon buttons and list accessories.
- Pick one base spacing unit and use only multiples of it. No arbitrary values.

**Keyboard**

- The grams field uses `.decimalPad`, and the decimal separator matches the
  user's locale.
- Content scrolls out from under the keyboard. The focused field is always
  visible.
- Tapping outside the field, or scrolling, dismisses the keyboard.
- Validate on the fly: reject negative and non-numeric input rather than
  crashing the parser later.

**Loading and state**

- Every asynchronous operation has a visible loading state.
- Guard against the spinner flash: if the work finishes in under 150 ms, do not
  show a spinner at all.
- Every list has a designed empty state containing a primary action, not just a
  sentence of text.
- Every error state offers a retry, and states plainly what failed.
- Disable the primary button while its action is in flight so it cannot be
  double-tapped into a double push or a duplicate entry.

**Typography and accessibility**

- All text scales with Dynamic Type. Verify at the largest accessibility size:
  nothing may clip or overlap.
- Every icon-only control has an `accessibilityLabel`. Decorative images are
  marked as decorative so VoiceOver skips them.
- Colour is never the only signal. Pair it with a label, a shape or an icon.
- Honour Reduce Motion: replace movement-heavy transitions with a fade.
- Meet contrast requirements against the palette in section 7. Check the muted
  colour against the background specifically; that is where these palettes fail.

**Formatting**

- Format every number with `NumberFormatter`, never string interpolation. Group
  separators and decimal separators must follow the locale.
- Energy is shown as a whole number of kcal. Macros are shown with at most one
  decimal place.
- Round only at the point of display. Stored values keep full precision.
- Day boundaries use `Calendar.current.startOfDay(for:)` in the user's current
  time zone. Handle the day changing while the app is open, and handle the
  short and long days that daylight saving produces.
- Unknown macro values render as a dash or the word "unknown", never as 0.

**Motion and feedback**

- One haptic on a successful commit (a food logged, a target saved). No haptic
  on navigation.
- Animations are short (0.2 to 0.35 s) and use a single shared easing curve.
- Nothing animates on first appearance of a screen except an intentional entry
  transition.

**Navigation**

- Back always works and never loses entered data without asking.
- A destructive action (delete a log row, reset all data) is confirmed.
- Modal sheets can always be dismissed; there is no dead end.
- Deep state is restorable: relaunching returns the user to a sane screen.


Every item here is a defect if it is missing. Section 7.4 fixed the numbers —
this is where they have to show up on screen.

**Hierarchy and density**

- Every screen has exactly one dominant element (a hero number, a canvas, a
  primary card) that the eye lands on first. A screen where every element has
  equal weight reads as a spreadsheet, not a product.
- Related content is grouped into a card or a section with the elevation
  style from 7.4, not left floating on the bare background.
- Unused flat background is not "minimal" — see the density rule in
  `KNOWLEDGE.md`. If a screen has room left after the mechanic and the
  content, add a secondary surface (a stat strip, a recent-activity card, a
  related-item row), not a `Spacer`.

**Components**

- Every card, sheet, chip, row and button in the app uses the corner radius
  and elevation from section 7.4. No screen introduces its own radius or its
  own shadow value "just for this one card".
- Buttons have a pressed state (`ButtonStyle` with a scale or opacity change
  on `isPressed`) and a disabled state that is visibly different, not just
  non-interactive.
- Chips and badges are pill or rounded-rect shaped per 7.4, never a bare
  `Text` with no background sitting where a control is expected.
- A functional control (add, filter, sort, close, more, share, delete) is an
  SF Symbol inside a properly hit-targeted `Button`. SF Symbols are fine and
  expected here — section 16 only bans them as the app's primary brand
  iconography (app icon, empty-state hero, onboarding art), which is what the
  generated assets in section 13 are for.

**Depth and material**

- At least one surface in the app (a sheet, a modal, a floating toolbar) uses
  the elevation style from 7.4 to visibly sit above the content behind it.
  A flat app with no depth anywhere reads as a wireframe.
- Icons and generated art sit on the surface colour from 7.1, never directly
  on a colour that makes their edges disappear.

**Motion as feedback, not decoration**

- The one dominant element in a screen (7.4's primary control, the mechanic's
  hero) responds visibly to touch: a scale, a colour shift, a haptic — pick
  at least one. A control that looks identical pressed and unpressed reads as
  broken, not calm.

**Taste DNA (section 7.6)**

- Home uses the assigned layout family and density. Three identical equal-weight
  cards, a leftover bento hole, or a second column structure copied down the
  page is a defect.
- Copy follows the assigned voice. No em-dash, no elevate/unlock/seamless, no
  emoji, no SECTION 01 labels.
- Motion follows the assigned personality and honours Reduce Motion with a fade.
  One signature motion per view. No glow stacked on glass stacked on spring.
- Tokens by intent: the live verb wears accent; delete does not wear primary.


---

## 9. Concurrency

The target builds with Swift 6.2 and `SWIFT_STRICT_CONCURRENCY = complete`. It
must compile with **zero concurrency warnings**. Warnings here become crashes
later, so they are not negotiable.

- All UI types are `@MainActor`. Annotate the type, not individual methods.
- Any value crossing an actor boundary is `Sendable`. Prefer immutable structs
  of primitives.
- Do not use `@unchecked Sendable`. If it is genuinely unavoidable, it needs a
  comment explaining what guarantees the safety.
- No mutable global state. No `static var` that is written after launch.
- Networking and storage APIs are `async` and honour cancellation. When the
  search query changes, cancel the in-flight task; do not let a stale response
  overwrite fresh results.
- Use structured concurrency. Avoid `Task.detached` unless there is a stated
  reason. Never fire a `Task` that outlives the view without owning it.
- Never use `DispatchQueue.main.asyncAfter` to paper over an ordering problem.
  Fix the ordering.
- `Timer` and notification observers are invalidated in `deinit` or on
  disappear.


---

## 10. Persistence engineering

Chosen technology: **UserDefaults+Codable**

UserDefaults holds one Codable AskDocument (schemaVersion from 1, Names, Stalks, GageMark, Slips, DecisionRecords, fold Idle Gaged or Filed, daykeys as Int YYYYMMDD) encoded to JSON Data under ach.ask.v1. Fold state is stored as the ADT, not inferred in the view. In-memory AskStore is the source of truth. UserDefaults is the projection. Views never touch UserDefaults. Debounce writes. Flush when scenePhase becomes inactive or background and after Gage, Draw, Retract, or reset. Decoding failure falls back to ach.ask.v1.backup, then an empty Ask, never a crash. resetAllData() is reachable from Settings. Tests use a private UserDefaults suite. Simulator seed only once behind ach.demo.v1 writes a dispute Ask of two pledged Names so Draw is enabled, files several Slips so History is a used product, marks onboarding complete, and never seeds Bare as the first frame. Never seed on a device.

This app persists to **files on disk**. The following are mandatory.

- Write atomically. Either `Data.write(to:options: .atomic)` or write to a
  temporary file and `FileManager.replaceItemAt`. A non-atomic write that is
  interrupted leaves a truncated file and the app will not launch.
- Create the containing directory with
  `withIntermediateDirectories: true` before the first write.
- Every document carries a `schemaVersion` field from version 1, and the decoder
  switches on it.
- Decoding failure must be recoverable: keep the previous good file as a
  `.backup`, fall back to it, and if that also fails start from empty state and
  tell the user. Never crash on a corrupt file.
- All file IO happens off the main thread. The main thread never blocks on disk.
- Debounce writes during rapid edits, but force a flush when `scenePhase`
  becomes `.inactive` or `.background`, and after any destructive action.
- Exclude caches from backup with `URLResourceValues.isExcludedFromBackup` where
  appropriate; user data belongs in Application Support and should be backed up.
- Keep an explicit in-memory source of truth and treat the file as a projection
  of it, so a failed write never leaves the UI showing data that does not exist.


Regardless of technology:

- One seam between domain logic and storage; the UI never touches storage types.
- Writes survive a force-quit. Do not rely on `applicationWillTerminate`.
- Provide `resetAllData()`, used by tests and reachable from Settings.

---

## 11. Networking

- One client type owns both Open Food Facts endpoints.
- Set `User-Agent` on every request. Open Food Facts throttles clients that do
  not identify themselves.
- 15 second timeout. One retry on a transient transport failure, then a typed
  error. Do not retry a 404.
- Cancel the in-flight search when the query changes. Debounce input by roughly
  300 ms.
- Decode into DTO types that mirror the JSON exactly, then map to domain types.
  Never decode straight into your domain model.
- Dedicated `JSONDecoder` with `.useDefaultKeys`. Never `convertFromSnakeCase` —
  Open Food Facts keys like `energy-kcal_100g` break snake_case conversion.
- Resolve a scanned code with `GET /api/v2/product/<barcode>.json`, not a search.
- Open Food Facts data is user-contributed and frequently incomplete. Every
  numeric field is optional. A product with no energy value is a normal case
  that the UI must present, not an error.
- Some numeric fields arrive as strings. The decoder must accept both a number
  and a numeric string for every nutriment.
- `status` of `0` in the product response means not found. Map it to a distinct
  error case so the UI can offer manual entry.
- Never crash on malformed JSON. A decoding failure is a handled error.
- Cache every resolved product locally on success, so the app degrades to a
  working offline catalogue.


Set `User-Agent: Achillea/1.0 (iOS; +https://achillea-ask.pro)` on every request. Never reuse another app's string.
No required remote catalog. Network only if this product actually needs it.

---

## 11b. App Store readiness

The app must be submittable without further work.

- `PrivacyInfo.xcprivacy` in the target, declaring the UserDefaults access API
  reason `CA92.1` and the file timestamp reason `C617.1`, with
  `NSPrivacyTracking` false and no collected data types.
- `INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO` in the pbxproj so TestFlight
  does not sit on Missing Compliance.
- `NSCameraUsageDescription` written specifically for this app. Generic strings
  get rejected.
- `LSApplicationCategoryType` of `public.app-category.healthcare-fitness`.
- Portrait only, iPhone and iPad (`TARGETED_DEVICE_FAMILY = "1,2"`).
- No account, no sign-in, no delete-account flow, no in-app purchase, no ads, no
  user-generated content, and therefore no report or block UI.
- App Tracking Transparency is never invoked.
- The camera is the only sensitive permission requested.
- Guideline 5.1.1 (Privacy): do not encourage or direct the user to grant camera
  access. A pre-permission screen may exist, but the proceed button must be
  **Continue** or **Next** — never "Allow camera", "Enable camera",
  "Grant camera", or a bare Allow/Enable that calls `requestAccess`. The
  system dialog is the only Allow. Denied/restricted offers Open Settings.
- The app must not present itself as a clinician or as medical advice.
- Guideline 4.2 (Design — Minimum Functionality): the binary must be a native
  product, not a web browsing experience. No WKWebView / SFSafariViewController
  / UIWebView as home, a tab, or the primary UX. A content catalog, article
  reader, or site wrapper that could be a website is a reject. Push
  notifications, Core Location, and sharing do not make that acceptable.
- Guideline 1.4.1 (Safety — Physical Harm): if the binary shows health or
  medical recommendations, body-based targets, dosages, "you should" guidance,
  or product health claims (food, drink, supplement, remedy), put citations
  in the app. Tappable links to the sources, easy to find: same screen as the
  claim, or a Sources row one tap from Settings. Name the source (Open Food
  Facts, USDA FoodData Central, WHO, NIH MedlinePlus, …) and link it. A
  "not medical advice" footer without sources is a reject. A personal log
  that never advises does not invent claims to cite.
- Nutrition catalog data is credited to the database this app actually uses
  (Open Food Facts unless the spec names another). Credit is a tappable link,
  not a dead "OpenFoodFacts" label.


Ignore the food-log and Open Food Facts lines above when they conflict with this
family. Category for this app is `public.app-category.lifestyle`. Camera permission only if the
product actually captures.

Project settings that follow from the above:

```yaml
INFOPLIST_KEY_UIUserInterfaceStyle: Dark
INFOPLIST_KEY_UISupportedInterfaceOrientations: UIInterfaceOrientationPortrait
INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad: UIInterfaceOrientationPortrait
INFOPLIST_KEY_UIRequiresFullScreen: YES
INFOPLIST_KEY_ITSAppUsesNonExemptEncryption: NO
INFOPLIST_KEY_LSApplicationCategoryType: public.app-category.lifestyle
TARGETED_DEVICE_FAMILY: "1,2"
SWIFT_STRICT_CONCURRENCY: complete
```

---

## 12. Functional twist: Gage-then-draw (the name list freezes before the pick; Draw on Idle is refused)

Home is gage-then-draw. The chooser pledges the Name table first, Gage freezes that table and writes a GageMark, and only then does Draw file a Slip. Draw before Gage does nothing. A later Gage while Gaged does nothing. Gage on a crate under two Names writes Bare. The dispute path writes two Names at even mass, keeps the stalk rails out, and skips Gage so the opening Draw can file from Idle. Launch already pledges two Names on that dispute path so the seeded home verb is live. Retract peels the newest Slip. History lists filed Slips only. Settings names the seeded generator. There is no post-pick reject, no party wheel, and no criteria matrix.

This is the app's marketed differentiator. It must be:

- visible on the home screen, not buried in settings;
- backed by real persisted data, not a cosmetic flourish;
- covered by at least one unit test;
- described in the README as the reason a user would pick this app.

---

## 13. AI-generated assets

Art style: **Neon outline glowing line art · typographic**


Base prompt, reused and extended for every asset:

```
Neon outline glowing line art, typographic, hairline luminous contours around solid yarrow and milfoil forms, agency poster crop, quiet uncluttered ground, studio glow, no text, no letters, no logo, no specified colours
```

All 12 images below are required. Generate each one, export
as PNG, and add it to `Assets.xcassets` as its own image set named exactly as
given. Every name carries the `ach_` prefix.

### 13.1 App icon rules (strict)

The icon is rejected by App Store Connect if any of these are wrong:

- Exactly **1024 x 1024 px**.
- **No alpha channel.**
- sRGB colour profile, 8 bits per channel, PNG.
- **No text and no words** in the artwork.
- **No rounded corners and no built-in mask.**
- The subject stays inside the middle 80%.

### 13.2 Full asset list

| # | Image set | Size (px) | Alpha | Purpose |
| --- | --- | --- | --- | --- |
| 1 | `ach_AppIcon` | 1024x1024 | **NO** | App Store icon. NO alpha channel, NO transparency, NO text, NO rounded corners, NO drop shadow outside the canvas. |
| 2 | `ach_Splash` | 1290x2796 | fill | Launch background. The middle third must stay quiet so the wordmark reads on top. |
| 3 | `ach_Onboarding1` | 1024x1536 | **required cutout** | Onboarding page 1 illustration: what the app is for. |
| 4 | `ach_Onboarding2` | 1024x1536 | **required cutout** | Onboarding page 2 illustration: the main verb. |
| 5 | `ach_Onboarding3` | 1024x1536 | **required cutout** | Onboarding page 3 illustration: why they stay. |
| 6 | `ach_EmptyHome` | 1024x1024 | **required cutout** | Empty state: the home screen has nothing yet. Calm and inviting, never sad. |
| 7 | `ach_EmptyList` | 1024x1024 | **required cutout** | Empty state: a secondary list has no rows. |
| 8 | `ach_CardBackdrop` | 1200x800 | fill | Backdrop art for a primary card. Low contrast so text stays readable. |
| 9 | `ach_ControlFace` | 512x512 | **required cutout** | Custom control artwork used for the primary interactive element. |
| 10 | `ach_TwistHero` | 1024x1024 | **required cutout** | Hero art for the 'Gage-then-draw (the name list freezes before the pick; Draw on Idle is refused)' feature screen. |
| 11 | `ach_SuccessMark` | 512x512 | **required cutout** | Shown briefly when the primary action succeeds. |
| 12 | `ach_HeaderDecor` | 1200x600 | **required cutout** | Decorative header accent on the main screen. |

### Prompt per asset

**`ach_AppIcon`** — 1024x1024

```
Solid yarrow umbel as a typographic neon-outline emblem filling the canvas, opaque field, no text, no letters, no rounded corners, no drop shadow, subject inside the middle 80 percent
```

**`ach_Splash`** — 1290x2796

```
Tall typographic neon-outline milfoil stalks with a quiet uncluttered centre band, glowing line art, no text
```

**`ach_Onboarding1`** — 1024x1536

```
A bound sheaf of solid yarrow waiting for names, neon outline on an opaque subject, transparent corners, no text

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`ach_Onboarding2`** — 1024x1536

```
A hand closing a gage clip on a solid name tablet, mid-gesture freeze before the draw, neon outline, opaque subject, transparent corners, no text

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`ach_Onboarding3`** — 1024x1536

```
A short stack of solid filed slips beside a milfoil stalk, meaning accumulated, neon outline, opaque subjects, transparent corners, no text

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`ach_EmptyHome`** — 1024x1024

```
A solid closed wooden crate of unused stalks, fully opaque wood in the center, transparent corners, waiting, not glass, not a hollow wire frame, neon outline, no text

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`ach_EmptyList`** — 1024x1024

```
A solid empty slip sleeve of folded cloth, opaque fabric in the center, transparent corners, neon outline, no text

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`ach_CardBackdrop`** — 1200x800

```
Abstract typographic neon-outline wash of faint milfoil lines filling the canvas, low contrast so type stays readable, no text
```

**`ach_ControlFace`** — 512x512

```
Face of a single solid gage clip, opaque metal, transparent corners, neon outline, no text

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`ach_TwistHero`** — 1024x1024

```
A frozen name tablet locked under a gage clip before any slip is drawn, solid subject, transparent corners, neon outline, no text

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`ach_SuccessMark`** — 512x512

```
A small solid filed slip stamped shut, opaque paper, transparent corners, neon outline, no text

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`ach_HeaderDecor`** — 1200x600

```
Wide typographic neon-outline milfoil frond band filling the canvas, no text

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```


### 13.3 Asset rules

- Cut-outs (everything except AppIcon, Splash, CardBackdrop): isolated subject,
  real PNG alpha, all four corners transparent. No square plate.
- Assets must be semantically different from each other.
- Record the exact prompt used for every asset in the README.
- SF Symbols are permitted only for close, chevron, share and similar system
  affordances.

Scanner frames, reticles, and seamless tiles are drawn in SwiftUI via `Path` or `Shape`. GenerateImage is not used for those. Every other in-app graphic (except AppIcon, Splash, CardBackdrop) is a **cutout**: isolated SOLID opaque subject in the center, real PNG alpha, all four corners transparent. An opaque square plate inside a circle or pentagon is a fail. A hollow glass box or wire frame with a transparent center is a fail.

---

## 14. Demo data

Seed a small local demo dataset for this family's entities so Simulator
screenshots are not empty. The same seed must mark onboarding complete and
fill the primary surface — otherwise `-ReviewScreen` never fires. Never seed
on a physical device. Guard with `#if targetEnvironment(simulator)` and
`ach.demo.v1`.

Seed the happy path: the home primary verb is enabled. The blocked / gated /
error state is a unit-test fixture, not Simulator home. Home chrome names the
job and the next tap in words a stranger knows. Axis values (`ui`, `naming`,
`architecture`) never become user-visible titles. A card that looks tappable
is a `Button`. A readout does not use button chrome.

---

## 16. Anti-patterns

The following will fail review:

- `try!`, `as!`, or force-unwrapping anything derived from the network, the
  database or a file.
- `fatalError` anywhere reachable at runtime. It is acceptable only for a
  programmer error in an initialiser that cannot fail in practice, and needs a
  comment.
- Swallowing an error with an empty `catch`.
- `print` used as production logging.
- A hard-coded hex colour outside the single colour accessor.
- A hard-coded font name outside the single typography accessor.
- An SF Symbol used as the app's brand iconography — the app icon, the
  empty-state hero, or onboarding art. Those come from section 13. SF Symbols
  are the right choice for every functional control (add, filter, sort,
  close, share, delete) — leaving those as bare text instead of a symbol is
  also a defect.
- Storing a value that can be computed (day totals, remaining budget, macro
  percentages).
- Blocking the main thread on disk or network work.
- `UIScreen.main` for sizing. Use the geometry the layout system gives you.
- Index positions used as list identity. Identity is a stable identifier.
- A view that reaches into the persistence layer directly, bypassing the
  architecture's designated seam.
- Business logic inside a `View` body or a `UIViewController` method, when the
  assigned architecture places it elsewhere.
- Copying a source file from another app in this batch.
- A `TabView` with exactly three tabs. That is the factory stamp — two or
  four-to-five destinations, or a different chrome. ReviewScreen keys are
  not tabs.


---

## 17. Tests

Add a unit test target `AchilleaTests` covering at minimum:

1. The core domain invariant of this family (the thing that would be wrong if
   the calculator, decay, crate, or log lied).
2. Empty, populated and invalid input paths for the primary verb.
3. The section 12 twist logic.
4. One architecture-specific test proving the pattern holds.
5. A persistence round-trip: write, relaunch-equivalent reload, verify.
6. Parse `ProcessInfo.processInfo.arguments` once after onboarding. 
   `-ReviewScreen today|log|goals` switches the running app's live navigation. Extra cover slugs open those screens.
   Cover that parser with a unit test. Do not host a `View` in the test.

---

## 18. README.md

Write `README.md` at the app folder root covering:

1. What the app does and who it is for.
2. The architecture used and **why** it suits this product.
3. The unique feature added and how it works.
4. The AI art style and the exact prompt used for every asset.
5. How this app differs from others in the batch.
6. Build instructions.

---

## 19. Definition of done

**Build**
- [ ] `xcodegen generate` succeeds.
- [ ] `xcodebuild -scheme Achillea -destination 'generic/platform=iOS' build` succeeds.
- [ ] Zero new compiler warnings.
- [ ] Strict concurrency `complete` compiles clean.
- [ ] Test target passes.

**Function**
- [ ] Onboarding to first successful primary action works on a clean install.
- [ ] Every screen in section 3.6 exists and handles empty / filled / error.
- [ ] Reset and contact link live in Settings.
- [ ] Force-quitting immediately after a write loses nothing.
- [ ] Seeded home names the job and next tap; primary verb enabled.
- [ ] App reads `-ReviewScreen today|log|goals` after onboarding.

**Uniqueness**
- [ ] Architecture matches **Milfoil ADT fold (Idle | Gaged | Filed); the ask is a fold over Names; Gage writes a GageMark and freezes the Names and folds Idle to Gaged; Draw writes a Slip by massed chance and folds Gaged to Filed; Draw on Idle is refused; a second Gage while Gaged is refused; Gage samples an Ask with at least two Names; empty ask writes Bare; dispute path writes two Names at even mass and skips Gage so Draw from Idle may file** with no leakage across layers.
- [ ] UI approach matches **UIKit UITableView NIB registered cells · spritekit-accent**.
- [ ] Custom rendering, if any, is confined to one hero surface (section 7.5).
- [ ] Navigation matches **Stalk-locked chrome (the milfoil rail never leaves; History and Settings arrive as sheets)**.
- [ ] Screen composition follows section 3.6.
- [ ] Typography uses **SF Pro** and nothing else.
- [ ] Palette matches section 7.1 exactly.
- [ ] Home rhythm and motion match section 7.6. No second look.

**Quality**
- [ ] Section 8 UI/UX bar satisfied end to end.
- [ ] Contact link present.
- [ ] `PrivacyInfo.xcprivacy` present and correct.
- [ ] README complete.

---

## 20. Build commands

```bash
cd Achillea
xcodegen generate
xcodebuild -scheme Achillea -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build
xcrun simctl list devices available
xcodebuild -scheme Achillea -destination 'platform=iOS Simulator,id=<UDID>' test
```

Signing is off only on that command line. Do not put CODE_SIGNING_ALLOWED, CODE_SIGNING_REQUIRED, CODE_SIGN_IDENTITY or DEVELOPMENT_TEAM in project.yml — CI signs the archive. Leave CODE_SIGN_STYLE: Automatic as the scaffold set it. The exact simulator does not matter — use any available UDID from the list.
