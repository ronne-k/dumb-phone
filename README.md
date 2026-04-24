# DumbPhone

Minimal iPhone launcher app plus WidgetKit extension that shows app names as text instead of icons.

## How it works

- The app stores a list of launcher items with a visible label and a Shortcut name.
- The widget renders those labels in a clean text-only layout.
- Tapping a widget item opens the host app with a custom URL.
- The host app immediately runs the matching shortcut using Apple's documented Shortcuts URL scheme:
  `shortcuts://run-shortcut?name=...`

## Why Shortcuts are used

iOS widgets don't get full arbitrary app-launch behavior on their own. The supported pattern is to use widget links/URLs to open the containing app, then let the app handle the next step. This project routes taps through the app and then launches the named Shortcut, which can open another app with that app's URL scheme or built-in Shortcuts action.

## Setup

1. Open [TextLauncher.xcodeproj](/Users/ronnekent/Documents/GitHub/minimalist phone setup/TextLauncher.xcodeproj).
2. In Signing & Capabilities, choose your team for both targets.
3. Replace the placeholder bundle identifiers if you want:
   - App: `com.example.DumbPhone`
   - Widget: `com.example.DumbPhone.Widget`
   - App Group: `group.com.example.DumbPhone`
4. Create iOS Shortcuts whose names match the launcher items you want to use.
5. Run the app once, edit the list, then add the widget to your Home Screen.

## Notes

- The widget currently supports `systemMedium` and `systemLarge` because those sizes allow multiple tap targets with `Link`.
- The first launch seeds a starter set of text entries inspired by your mockup.
- The widget reads from a shared App Group `UserDefaults` store.
- Home Screen widgets do not support scrolling or arbitrary heights, so this project supports multiple widget pages instead. Add more than one widget and set each widget's page in the widget configuration UI.
