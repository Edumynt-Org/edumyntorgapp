# Edumynt App Design System

> Source of truth for Edumynt Flutter app design constraints and styling rules. Last Updated: 2026-08-15.

## Core Philosophy
1. **Flat & Clean**: No drop shadows, no 3D elements, no nested cards. White space and typography create the hierarchy.
2. **Accessible**: High contrast, bold typography, simple readable layouts.
3. **Consistent Tokens**: Never hardcode sizing, padding, colors, or radii. Always use tokens from `lib/core/theme/`.

## Typography
We use a two-font system, loaded via `google_fonts`:
- **Headings & Titles (`display`, `headline`, `title`)**: **Nunito**
  - Slightly rounded terminals to match our brand's default 16px radius.
- **Body & UI (`body`, `label`)**: **Inter**
  - Highly legible for dense UI, input fields, and reading text.

## Token System

### 1. Spacing (`AppSpacing`)
File: `lib/core/theme/app_spacing.dart`
Use for padding, margins, and `SizedBox` gaps.
- `xs` (4px): Micro gaps.
- `sm` (8px): Tight component grouping (Title to Subtitle).
- `md` (16px): Default padding, default component gap.
- `lg` (24px): Standard section breaks.
- `xl` (32px): Major section breaks.
- `xxl` (48px): Page boundaries, dramatic whitespace (Header block to Form block).
- `xxxl` (64px): Empty state spacing.

### 2. Border Radius (`AppRadius`)
File: `lib/core/theme/app_radius.dart`
- `sm` (4px): Small elements (badges, tags).
- `md` (8px): Inner cards or lists.
- `lg` (16px): **Default Brand Radius**. Used for all inputs, buttons, bottom sheets, and main cards.
- `xl` (24px): Large containers or image radii.
- `pill` (999px): Fully rounded elements (chips, circular buttons).

### 3. Component Sizes (`AppSizes`)
File: `lib/core/theme/app_sizes.dart`
- **Button Height (`buttonHeight`)**: 48px
- **Input Height (`inputHeight`)**: 48px
- **Icons**: 16px (`sm`), 24px (`md` - default), 32px (`lg`), 48px (`xl`).

### 4. Colors (`AppColors`)
File: `lib/core/theme/app_colors.dart`
Never hardcode hex values. Use `Theme.of(context).colorScheme` or `AppColors` directly.
- **Primary**: Brand color for main actions.
- **Surface**: Background for inputs and cards.
- **Background**: Canvas color.
- **Text**: `textLight` / `textDark`.
- **Muted Text**: `textMutedLight` / `textMutedDark` for hints and subtitles.

## Standardized Components
Use standard application wrappers instead of raw Material widgets where possible:
- `AppButton`: Replaces `ElevatedButton`/`TextButton`. Enforces 48px height, 16px radius, and standard loading states.
- `AppTextField`: Replaces `TextFormField`. Handles password visibility (`isPassword`), Material 3 floating labels, and consistent padding.

## Forms
- Use placeholder hint text like `••••••••` for passwords, and rely on the global muted `hintStyle` to ensure it stays subtle and doesn't compete with the primary focused color.
- Passwords must have an eye icon to toggle visibility natively.
