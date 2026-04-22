# Management/Settings Framework Comparison

## Slice Summary
- Slice: Management/Settings
- Files analyzed: 7
- Portable: 1
- Adapter needed: 5
- Rewrite: 1

## Criteria Scores
| Target | SwiftUI shape fit | AppKit detachment burden | Windows-native affordance fit | Theming/layout carryover | Expected manual rewrite cost | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| swiftcrossui | 10 | 7 | 6 | 9 | 8 | 40 |
| shaft | 6 | 7 | 9 | 6 | 4 | 32 |

## Recommendation
**Recommended target:** `swiftcrossui`

- The slice is dominated by portable or adapter-based SwiftUI files, which favors a SwiftUI-shaped migration path.
- Only `ServerView.swift` is a hard rewrite; the remaining files mainly need service adapters and Helios-owned chrome.
- Keep the generated `shaft` scaffold as a comparison harness while the shared Windows platform services settle.

## Per-Target Notes
### `swiftcrossui`
- High SwiftUI surface-area match for sidebar, header, and tab composition.
- Lower manual rewrite cost for the first Helios slice.
- Still needs explicit Windows adapters for clipboard, external links, and file picking.

### `shaft`
- Strong Windows-native posture once the Helios shell grows beyond the first slice.
- Higher manual rewrite pressure for SwiftUI-shaped management primitives.
- Best kept as the parallel comparison scaffold until shared services stabilize.

