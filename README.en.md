# `_UINavigationBarPalette` vs `UIScrollEdgeElementContainerInteraction`

*日本語版: [README.md](README.md)*

Supporting material for interoperability request **FB22730304** (make `_UINavigationBarPalette`
public) and the related Code-Level Support case.

In response to FB22730304 we were advised that `UIScrollEdgeElementContainerInteraction` can
achieve what the request asks for. This repository implements the same UI with both APIs and
**separates, level by level, what the public API can do and where it stops being able to do it.**

## Conclusion

**For Level 1, the advice is correct.** `UIScrollEdgeElementContainerInteraction` handles the
scroll edge effect completely, and there is no reason to reach for the palette at that level.
Level 2 is also workable with public API, at a cost.

The problem starts at Level 3.

| Level | Goal | `UIScrollEdgeElementContainerInteraction` | `_UINavigationBarPalette` |
|---|---|---|---|
| 1 | Apply the scroll edge effect behind a custom bar | ✅ **Works** — this is what the API is for | — |
| 2 | Make the custom bar occupy layout space | △ Possible by hand (requires restructuring the screen) | ✅ Automatic |
| 3 | Track the bar's bottom edge while a large title collapses | ✗ Lags and jitters | ✅ |
| 4 | Compose with a stacked search bar | ✗ No placement, no visibility control | ✅ |
| 5 | Stay in sync with the bar on push/pop | ✗ Two unrelated animations | ✅ |
| 6 | Participate in iOS 27 bar minimization | ✗ Cannot participate | ✅ |
| 7 | **The real use case** (Levels 3 + 4 + 5) | ✗ | ✅ |

### The dividing line is whether the navigation bar's own height changes

That single question separates Levels 1–2 from Level 3 onward.

As long as the bar's height is fixed, pinning a custom bar to the top of the safe area and pushing
the content inset down by a constant works. The moment the bar's height starts moving — a large
title collapsing, a search bar activating or dismissing, iOS 27 bar minimization — it breaks,
because **there is no public way for a view outside the bar to follow that**.

What FB22730304 asks for is therefore not a visual effect, but **a way to be a component that the
navigation bar itself lays out**.

## The two APIs

### `UIScrollEdgeElementContainerInteraction` (iOS 26.0)

The entire public surface, per the iOS 27.0 SDK header:

```objc
UIKIT_FINAL UIKIT_EXTERN NS_SWIFT_UI_ACTOR API_AVAILABLE(ios(26.0), tvos(26.0), visionos(26.0))
@interface UIScrollEdgeElementContainerInteraction : NSObject <UIInteraction>
/// The scroll view to affect
@property (nonatomic, nullable, weak) UIScrollView *scrollView;
/// The edge of the scroll view to affect
@property (nonatomic) UIRectEdge edge;
@end
```

The header describes its purpose itself:

> Add this interaction to a container view of views that overlay the edge of a scroll view.
> Any descendants of this view that should **affect the shape of the edge effect**, such as labels,
> images, glass views, and controls, will automatically do so.

It is a mechanism for letting views participate in the shape of the scroll edge effect.

### `_UINavigationBarPalette`

A `UIView` conforming to `_UINavigationBarLayoutParticipating`
(`-updateLayoutData:layoutWidth:`), owned by `UINavigationItem` as `_topPalette` / `_bottomPalette`,
and laid out by `UINavigationBar` as part of the bar itself. It is a navigation bar component.

The two operate at different layers, which is why the first cannot substitute for the second.

## Running it

Open `Package.swift` in Xcode 27 or later and run the Xcode Previews in
`Sources/Comparison/Levels/`. Each preview name carries its verdict.

| Preview | Content |
|---|---|
| `Lv1 Public ✅` | What the public API does achieve — scroll to see the effect (no palette version needed) |
| `Lv2 Public △` / `Lv2 Palette` | Achievable by hand, at a cost |
| `Lv3 Public ✗` / `Lv3 Palette` | Large title |
| `Lv4 Public ✗` / `Lv4 Palette` | Search bar |
| `Lv5 Public ✗` / `Lv5 Palette` | Push / pop |
| `Lv6 Public ✗` / `Lv6 Palette` | iOS 27 bar minimization |
| `Lv7 Public ✗` / `Lv7 Palette` | **The real use case. This pair alone shows the whole picture** |

Each level's goal, result, verdict and reproduction steps are documented at the top of the
corresponding source file (in Japanese).

### Start here

Run **`Lv7 Public ✗`** and **`Lv7 Palette`** side by side and walk through them in this order:

1. At rest, compare where the picker sits relative to the search field.
2. Scroll up slowly and let the large title collapse (Level 3 — the lag).
3. Flick to the top and let it bounce (the lag is at its worst here).
4. Activate the search field, then dismiss it (Level 4 — the inset breaks).
5. Tap Push, then drag the interactive back gesture slowly (Level 5 — the transition desync).

This is a large title, a stacked search bar, and a picker directly below it: the pattern used by
Music, Photos, Mail and Fitness.

## Layout

```
Sources/
  UIKitCorePrivate/            # Private headers (generated from iOS 26.5 with ipsw)
  Comparison/
    PaletteViewController.swift      # Palette version (reference behavior)
    PublicAPIViewController.swift    # Public API version (best attempt)
    Support/
      ListViewController.swift       # Shared list screen
      FilterSegmentedControl.swift   # Shared picker
      Scenario.swift                 # Gives both implementations identical conditions
    Levels/
      Level1_ScrollEdgeEffect.swift … Level7_RealWorldUseCase.swift
```

Both implementations take the same `Scenario`. The previews for each level differ only in which
options they enable.

The difference in implementation size is itself evidence. The palette version is three lines:

```swift
let palette = _UINavigationBarPalette(contentView: FilterSegmentedControl())!
palette.preferredHeight = scenario.barHeight
navigationItem._bottomPalette = palette
```

The public API version needs four steps — re-hosting the list as a child view controller,
constraints, the interaction, and a manual inset — of which the public API covers only one
(see comments 1–4 in `PublicAPIViewController.swift`).

## What is being requested

Access to existing behavior only; no new behavior. The minimum public surface would be:

```swift
// UINavigationBarPalette
init(contentView: UIView)
var preferredHeight: CGFloat
var minimumHeight: CGFloat
var displaysWhenSearchActive: Bool

// UINavigationItem
var topPalette: UINavigationBarPalette?
var bottomPalette: UINavigationBarPalette?
```

## References

- Apple Developer Forums [#808436](https://developer.apple.com/forums/thread/808436) — the same
  question as this one ("how do I do SwiftUI's `.safeAreaBar(edge: .top)` in UIKit?"), answered
  with the same suggestion of `UIScrollEdgeElementContainerInteraction`. That thread also carries
  a report that the edge effect does not extend full width while the navigation bar is visible.
- SwiftUI has a public API for this pattern, `.safeAreaBar(edge:)`. UIKit has no equivalent, so
  UIKit apps must either depend on private API or migrate to SwiftUI.

## Notes on accuracy

- Setting `_UINavigationBarPalette.pinned` produced no observable change in our testing. It is not
  part of what FB22730304 asks for.
- `UINavigationController.attachPalette(_:isPinned:)` behaved identically to assigning
  `navigationItem._bottomPalette`.
- The differences at Levels 3, 5 and 6 are behavioral and are confirmed by screen recording.
  Every other difference follows from the SDK headers alone.
- The headers in `Sources/UIKitCorePrivate/include/` were generated from iOS 26.5 with
  [ipsw](https://github.com/blacktop/ipsw), and are bundled only so that the comparison builds.

## Verified with

- Xcode 27.0 (27A266a) / iOS 27.0 SDK
- Builds with `xcodebuild -scheme Comparison -destination 'generic/platform=iOS Simulator'`
