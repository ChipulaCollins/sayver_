# Project: Sayver Grok Hub Overhaul

## Architecture
- **Framework**: Flutter 3.38.4 / Dart 3.10.3
- **Design Paradigm**: Grok Hub High-Density Dynamic Hub Aesthetic
- **Color System**: Strictly `#312C51` (Deep Navy), `#48426D` (Muted Slate), `#F0C38E` (Warm Peach), `#F1AA9B` (Soft Coral)
- **Typography**: Plus Jakarta Sans (`google_fonts`)
- **State Architecture**: `_HomeScreenState` with centralized mutations, `StorageService` persistence (`SharedPreferences` + in-memory fallback), reactive state passing to stateless/stateful components.
- **Responsive Layout**: Fluid column grid (2-3 cols on mobile, 4-6 cols on wide viewports) with max-width 1040px constraint to prevent overstretching.

## Feature Inventory
| # | Feature | Description | Milestone | Source |
|---|---------|-------------|-----------|--------|
| 1 | WCAG AA Contrast Compliance | Enforce 4.5:1 contrast for all text/icons in Light & Dark modes; prohibit bare peach on light surfaces | M1 | ORIGINAL_REQUEST §R4 |
| 2 | Brand Palette & Typography | Retain exact 4 brand colors; Plus Jakarta Sans typography scale | M1 | ORIGINAL_REQUEST §R4 |
| 3 | Legacy Model Compatibility | Maintain backward compatibility for `SavingsGoal.primaryColor` and color mappings | M1 | test/savings_goal_test.dart |
| 4 | Tactile Spring Physics | Touch-down scale compression and elastic spring release on envelope tiles | M2 | ORIGINAL_REQUEST §R2 |
| 5 | Envelope Contrast States | High-contrast visual distinction between active and completed envelopes with glowing badges | M2 | ORIGINAL_REQUEST §R2 |
| 6 | Envelope Test Finders | Preserve `InkWell`, `'#<index>'`, `'SAVED'`, note text, and amount finders | M2 | test/widgets_test.dart |
| 7 | CreateGoalDialog Overflow Fix | Remove rigid `maxHeight: 600`, introduce scroll-safe responsive bounds | M3 | ORIGINAL_REQUEST §R3 |
| 8 | AutoDepositDialog Overflow Fix | Constrain matched envelopes list inside scrollable viewport; eliminate unconstrained Wrap | M3 | ORIGINAL_REQUEST §R3 |
| 9 | SurpriseEnvelope 3D Flip Card | Responsive 3D flip card card container with scroll safety | M3 | ORIGINAL_REQUEST §R3 |
| 10 | Frosted Surfaces & Hairline Borders | Glassmorphism with `BackdropFilter` and 0.8px borders for all modals and sheets | M3 | ORIGINAL_REQUEST §R3 |
| 11 | Segment Detail & Note Editor | Modernized sheet for viewing/editing segment note and completion status | M3 | ORIGINAL_REQUEST §R3 |
| 12 | Top Bar Goal Switcher & Stat Pills | Compact goal switcher capsule with rapid stats (streak, pace/day, remaining) | M4 | ORIGINAL_REQUEST §R1 |
| 13 | Segmented Action Pill Toolbar | Integrated action toolbar above canvas (Draw, Quick Deposit, Shuffler, Insights), retiring bottom dock | M4 | ORIGINAL_REQUEST §R1 |
| 14 | Tactile Filter & Sort Chips | Streamlined interactive chips with instant responsive feedback (`All`, `Available`, `Saved`) | M4 | ORIGINAL_REQUEST §R1 |
| 15 | Hero Progress Card with Glow Gauges | Redesigned progress card with high-contrast glow gauges and milestone markers | M4 | ORIGINAL_REQUEST §R1 |
| 16 | Responsive Multi-Column Mesh | LayoutBuilder adaptive 2-3 to 4-6 columns with max-width bounds across 360px..1200px+ | M4 | ORIGINAL_REQUEST §R2 |
| 17 | Zero RenderFlex Overflows | Zero layout overflows from 360px mobile to 1200px+ desktop | M4 | ORIGINAL_REQUEST §Acceptance |
| 18 | E2E & Widget Test Suite Pass | 41 existing tests + new widget tests passing with 0 failures | M5 | ORIGINAL_REQUEST §Acceptance |
| 19 | Static Analysis & Web Build | `flutter analyze` 0 issues, `flutter build web` succeeds cleanly | M5 | ORIGINAL_REQUEST §Acceptance |
| 20 | Adversarial Coverage Hardening | White-box stress testing and edge-case verification (Tier 5) | M5 | ORIGINAL_REQUEST §Acceptance |

## Milestones
| # | Name | Scope | Dependencies | Status |
|---|------|-------|-------------|--------|
| M1 | Theme, Typography & Visual Foundation | `lib/theme/app_theme.dart` | none | DONE |
| M2 | Tactile Envelope Mesh & Micro-Interactions | `lib/widgets/envelope_tile.dart` | M1 | DONE |
| M3 | Seamless Modal Dialogs & Sheets Overhaul | `lib/widgets/*.dart` (dialogs & sheets) | M1 | DONE |
| M4 | Grok Hub Dashboard Architecture | `lib/main.dart`, `lib/widgets/goal_header_card.dart`, `lib/models/savings_goal.dart` | M1, M2, M3 | DONE |
| M5 | Final Integration, E2E Test Suite Pass & Adversarial Hardening | Full project validation, E2E test execution, Forensic Audit | M4, TEST_READY | DONE |

## Interface Contracts

### M1 ↔ M2, M3, M4 (AppTheme)
- `AppTheme.darkNavy`: `#312C51` (primary scaffold & dark deep bg)
- `AppTheme.mutedSlate`: `#48426D` (card surfaces, appbars, containers)
- `AppTheme.warmPeach`: `#F0C38E` (primary accent, golden highlights, active gauges)
- `AppTheme.softCoral`: `#F1AA9B` (secondary accent, badges, micro-accents)
- `AppTheme.textPrimary`: `#FAF8FC`
- `AppTheme.textSecondary`: `#C7C2E0`
- `AppTheme.textDark`: `#231E3D` (high-contrast text on bright peach/coral surfaces)
- `AppTheme.borderSlate`: `#5A5282`
- `AppTheme.lightBorder`: `#D8D1E8`
- `AppTheme.lightCard`: `#F4EFFB`
- `AppTheme.lightSurface`: `#FFFFFF`
- WCAG Rule: In light theme, any text on light background must use `textDark` (`#231E3D`) or `darkNavy` (`#312C51`). Warm Peach must only be used with high-contrast text or as a background fill with `textDark` text.

### M2 (EnvelopeTile)
- Constructor:
  ```dart
  const EnvelopeTile({
    super.key,
    required SavingsSegment segment,
    required String currencySymbol,
    required bool allowCents,
    required VoidCallback onTap,
    required VoidCallback onLongPress,
  });
  ```
- Must contain an `InkWell` ancestor/descendant for tap detection.
- Must render `#${segment.index}`, currency symbol with formatted amount, `SAVED` badge when completed, and note text if present.
- Spring physics: `onTapDown` triggers spring scale-down to ~0.94, `onTapUp` and `onTapCancel` trigger spring release with elastic/bounce curve.

### M4 (Grok Hub Dashboard & Action Bar)
- Top Bar:
  - Goal Switcher Capsule: Displays current goal title, tap triggers `_openGoalSwitcherSheet()`.
  - Rapid Stat Pills: Streak (`🔥 ${goal.currentStreakDays}d`), Pace (`⚡ ${goal.currencySymbol}${goal.estimatedDailyPace}/d`), Remaining (`${goal.currencySymbol}${goal.remainingAmount}`).
  - Theme toggle button with `tooltip: 'Toggle Theme'`.
- Segmented Action Pill Toolbar:
  - Positioned above the envelope grid (retiring floating bottom dock).
  - Actions:
    - Draw: Must contain text `'Draw'` and icon, triggers `_openSurprisePicker()`.
    - Quick Deposit: triggers `_openAutoDeposit()`.
    - Shuffler: triggers `_shuffleCurrentGoalSegments()`.
    - Insights: triggers `_openInsightsModal()`.
- Filter & Sort Bar:
  - Filter chips: `'All (${goal.segmentCount})'`, `'Available (${availableCount})'`, `'Saved (${completedCount})'`.

## Code Layout
- `lib/theme/app_theme.dart` — Theme definitions, colors, typography. Owned by M1.
- `lib/widgets/envelope_tile.dart` — Tactile tile component. Owned by M2.
- `lib/widgets/create_goal_dialog.dart` — Goal creation wizard. Owned by M3.
- `lib/widgets/auto_deposit_dialog.dart` — Quick auto-deposit sheet. Owned by M3.
- `lib/widgets/surprise_envelope_dialog.dart` — 3D flip card mystery draw. Owned by M3.
- `lib/widgets/segment_detail_dialog.dart` — Segment note & edit modal. Owned by M3.
- `lib/widgets/savings_jar_visualizer.dart` — Jar visualizer sheet. Owned by M3.
- `lib/widgets/analytics_view.dart` — Analytics & insights sheet. Owned by M3.
- `lib/widgets/celebration_dialog.dart` — Goal completion dialog. Owned by M3.
- `lib/widgets/share_progress_dialog.dart` — Share progress modal. Owned by M3.
- `lib/widgets/goal_header_card.dart` — Hero progress card. Owned by M4.
- `lib/models/savings_goal.dart` — Goal model (exposing `currentStreakDays`). Owned by M4.
- `lib/main.dart` — Top bar, action toolbar, responsive grid, dialog orchestration. Owned by M4.
- `test/` — Existing 41 unit/widget tests. Preserved without regression.
- `test/grok_hub_widget_test.dart` — New comprehensive widget tests. Owned by E2E Testing Track.
