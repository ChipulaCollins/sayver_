# E2E Test Infra: Sayver Grok Hub

## Test Philosophy
- Requirement-driven, opaque-box testing covering Grok Hub UI/UX overhaul requirements.
- Zero dependency on implementation internals; interaction solely via widget pump, finding public text/icons, and inspecting rendered layout.
- Methodology: Category-Partition + Boundary Value Analysis (BVA) + Pairwise Combinatorial Testing + Real-World Workload Testing.

## Feature Inventory
| # | Feature | Source (requirement) | Tier 1 | Tier 2 | Tier 3 |
|---|---------|---------------------|:------:|:------:|:------:|
| 1 | Grok Hub Action Pill Toolbar | ORIGINAL_REQUEST §R1 | 5 | 5 | ✓ |
| 2 | Top Bar Goal Switcher & Rapid Stats | ORIGINAL_REQUEST §R1 | 5 | 5 | ✓ |
| 3 | Tactile Interactive Filter & Sort Chips | ORIGINAL_REQUEST §R1 | 5 | 5 | ✓ |
| 4 | Hero Progress Card with Glow Gauges | ORIGINAL_REQUEST §R1 | 5 | 5 | ✓ |
| 5 | Tactile Envelope Mesh & Spring Physics | ORIGINAL_REQUEST §R2 | 5 | 5 | ✓ |
| 6 | Responsive Grid Layout (360px–1200px) | ORIGINAL_REQUEST §R2, §Acceptance | 5 | 5 | ✓ |
| 7 | Seamless Modals & Sheets (Zero Overflow) | ORIGINAL_REQUEST §R3 | 5 | 5 | ✓ |
| 8 | Theme Consistency & WCAG AA Contrast | ORIGINAL_REQUEST §R4 | 5 | 5 | ✓ |

## Test Architecture
- **Location**: `test/grok_hub_widget_test.dart`
- **Runner**: `flutter test test/grok_hub_widget_test.dart`
- **Pass/Fail Semantics**: All test cases must pass with exit code 0; zero unhandled exceptions, zero `RenderFlex` overflows in test logs.
- **Viewport Matrix**: 360x640 (compact mobile), 412x915 (standard mobile), 768x1024 (tablet), 1200x800 (desktop/web).

## Real-World Application Scenarios (Tier 4)
| # | Scenario | Features Exercised | Complexity |
|---|----------|--------------------|------------|
| 1 | Greenfield Onboarding to First Completion | Create Goal → Draw Envelope → Mark Saved → View Progress | Medium |
| 2 | High-Velocity Auto-Deposit Session | Auto-deposit batch → Verify remaining balance & pace updates | Medium |
| 3 | Viewport Resize & Orientation Shift | Mobile 360px to Desktop 1200px layout shift without RenderFlex overflow | High |
| 4 | Multi-Goal Switch & Theme Transition | Switch goals while filters active, toggle Dark/Light mode | High |
| 5 | Milestone Celebration & Progress Share | Complete 100% of envelopes → Trigger celebration & share dialog | High |

## Coverage Thresholds
- Tier 1: ≥5 per feature (happy-path isolation)
- Tier 2: ≥5 per feature (boundary, corner, extremes: empty goals, 100+ envelopes, extreme viewports)
- Tier 3: Pairwise coverage of major feature interactions
- Tier 4: ≥5 realistic user application scenarios
