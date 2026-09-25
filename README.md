# Achillea

Draw one pick from names you typed. Achillea is for people who need an honest choice, not a room spinner and not a scored matrix.

Pledge the names, Gage to freeze the list, then Draw. The opening seed is a two-name dispute so Draw can file immediately.

## Architecture

The Ask is a closed algebraic fold over Names with cases Idle, Gaged, and Filed. A fourth case is a defect.

This product needs that freeze. Gage writes a GageMark, locks every Name and its Stalk mass, and folds Idle to Gaged. Draw then runs a seeded massed chance and writes a Slip, folding Gaged to Filed. Draw on Idle is refused. A second Gage while Gaged is refused. Gage on fewer than two Names writes Bare.

The dispute path is the exception that keeps the opening verb live: two Names at even mass, stalk rails hidden, Gage skipped, Draw files from Idle.

AskStore is the in-memory source of truth. UserDefaults plus an atomic Application Support file is the projection. AskDesk pattern-matches the fold. Views call `gageAsk`, `drawSlip`, and `peelSlip` and never keep a parallel bool.

## Unique feature

Gage-then-draw. The name list freezes before the pick. That reverses the usual draw-then-reject flow. Retract peels the newest Slip. History lists filed slips only. Settings names the seeded generator.

## UI

Ask is the only full screen. The pledged Name table is a UIKit `UITableView` with NIB-registered cells. One SpriteKit milfoil accent lives on the numeric rail (name count, stalk sum, gage state). History and Settings arrive as sheets. No tab bar.

## Art

Style: neon outline glowing line art, typographic.

Base prompt, reused and extended for every asset:

```
Neon outline glowing line art, typographic, hairline luminous contours around solid yarrow and milfoil forms, agency poster crop, quiet uncluttered ground, studio glow, no text, no letters, no logo, no specified colours
```

| Asset | Prompt |
| --- | --- |
| `ach_AppIcon` | Solid yarrow umbel as a typographic neon-outline emblem filling the canvas, opaque field, no text, no letters, no rounded corners, no drop shadow, subject inside the middle 80 percent |
| `ach_Splash` | Tall typographic neon-outline milfoil stalks with a quiet uncluttered centre band, glowing line art, no text |
| `ach_Onboarding1` | A bound sheaf of solid yarrow waiting for names, neon outline on an opaque subject, transparent corners, no text |
| `ach_Onboarding2` | A hand closing a gage clip on a solid name tablet, mid-gesture freeze before the draw, neon outline, opaque subject, transparent corners, no text |
| `ach_Onboarding3` | A short stack of solid filed slips beside a milfoil stalk, meaning accumulated, neon outline, opaque subjects, transparent corners, no text |
| `ach_EmptyHome` | A solid closed wooden crate of unused stalks, fully opaque wood in the center, transparent corners, waiting, not glass, not a hollow wire frame, neon outline, no text |
| `ach_EmptyList` | A solid empty slip sleeve of folded cloth, opaque fabric in the center, transparent corners, neon outline, no text |
| `ach_CardBackdrop` | Abstract typographic neon-outline wash of faint milfoil lines filling the canvas, low contrast so type stays readable, no text |
| `ach_ControlFace` | Face of a single solid gage clip, opaque metal, transparent corners, neon outline, no text |
| `ach_TwistHero` | A frozen name tablet locked under a gage clip before any slip is drawn, solid subject, transparent corners, neon outline, no text |
| `ach_SuccessMark` | A small solid filed slip stamped shut, opaque paper, transparent corners, neon outline, no text |
| `ach_HeaderDecor` | Wide typographic neon-outline milfoil frond band filling the canvas, no text |

## How this differs

Klerion draws first and then accepts or rejects. Achillea pledges the field first. There is no post-pick reject, no party wheel, and no criteria matrix. Home is the Ask table with a numeric stalk rail.

## Build

```bash
cd Achillea
xcodegen generate
xcodebuild -scheme Achillea -destination 'generic/platform=iOS Simulator' build-for-testing
```

iOS 17, Swift 6.2, strict concurrency complete. No Swift packages.
