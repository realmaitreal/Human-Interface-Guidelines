[Human Interface Guidelines](../../README.md) › [Components](../../Components.md) › [Layout and organization](../Layout%20and%20organization.md) › **Labels**

# Labels

*A label is a static piece of text that people can read and often copy, but not edit.*

> **Note**
>
> Updated guidance to reflect changes in watchOS 10.

![A stylized representation of a text label. The image is tinted red to subtly reflect the red in the original six-color Apple logo.](https://developer.apple.com/tutorials/images/com.apple.HIG/components-label-intro@2x.png)

Labels display text throughout the interface, in buttons, menu items, and views, helping people understand the current context and what they can do next.

The term *label* refers to uneditable text that can appear in various places. For example:

- Within a button, a label generally conveys what the button does, such as Edit, Cancel, or Send.
- Within many lists, a label can describe each item, often accompanied by a symbol or an image.
- Within a view, a label might provide additional context by introducing a control or describing a common action or task that people can perform in the view.

> **Developer note**
>
> To display uneditable text, SwiftUI defines two components: [Label](https://developer.apple.com/documentation/swiftui/label) and [Text](https://developer.apple.com/documentation/swiftui/text).

The guidance below can help you use a label to display text. In some cases, guidance for specific components — such as [action buttons](../Menus%20and%20actions/Buttons.md), [menus](../Menus%20and%20actions/Menus.md), and [lists and tables](Lists%20and%20tables.md) — includes additional recommendations for using text.

## Best practices

**Use a label to display a small amount of text that people don’t need to edit.** If you need to let people edit a small amount of text, use a [text field](../Selection%20and%20input/Text%20fields.md). If you need to display a large amount of text, and optionally let people edit it, use a [text view](../Content/Text%20views.md).

**Prefer system fonts.** A label can display plain or styled text, and it supports Dynamic Type (where available) by default. If you adjust the style of a label or use custom fonts, make sure the text remains legible.

**Use system-provided label colors to communicate relative importance.** The system defines four label colors that vary in appearance to help you give text different levels of visual importance. For additional guidance, see [Color](../../Foundations/Color.md).

| System color | Example usage | iOS, iPadOS, tvOS, visionOS | macOS |
| --- | --- | --- | --- |
| Label | Primary information | [label](https://developer.apple.com/documentation/uikit/uicolor/label) | [labelColor](https://developer.apple.com/documentation/appkit/nscolor/labelcolor) |
| Secondary label | A subheading or supplemental text | [secondaryLabel](https://developer.apple.com/documentation/uikit/uicolor/secondarylabel) | [secondaryLabelColor](https://developer.apple.com/documentation/appkit/nscolor/secondarylabelcolor) |
| Tertiary label | Text that describes an unavailable item or behavior | [tertiaryLabel](https://developer.apple.com/documentation/uikit/uicolor/tertiarylabel) | [tertiaryLabelColor](https://developer.apple.com/documentation/appkit/nscolor/tertiarylabelcolor) |
| Quaternary label | Watermark text | [quaternaryLabel](https://developer.apple.com/documentation/uikit/uicolor/quaternarylabel) | [quaternaryLabelColor](https://developer.apple.com/documentation/appkit/nscolor/quaternarylabelcolor) |

**Make useful label text selectable.** If a label contains useful information — like an error message, a location, or an IP address — consider letting people select and copy it for pasting elsewhere.

## Platform considerations

*No additional considerations for iOS, iPadOS, tvOS, or visionOS.*

### macOS

> **Developer note**
>
> To display uneditable text in a label, use the [isEditable](https://developer.apple.com/documentation/appkit/nstextfield/iseditable) property of [NSTextField](https://developer.apple.com/documentation/appkit/nstextfield).

### watchOS

Date and time text components (shown below on the left) display the current date, the current time, or a combination of both. You can configure a date text component to use a variety of formats, calendars, and time zones. A countdown timer text component (shown below on the right) displays a precise countdown or count-up timer. You can configure a timer text component to display its count value in a variety of formats.

![An illustration of date and time text components on Apple Watch, with the date aligned to the leading edge and the time aligned to the trailing edge.](https://developer.apple.com/tutorials/images/com.apple.HIG/labels-date-time-text-component@2x.png)  
*Date and time labels*

![An illustration of a countdown timer text component on Apple Watch, with the time value at the center.](https://developer.apple.com/tutorials/images/com.apple.HIG/labels-countdown-timer-text-component@2x.png)  
*Timer label*

When you use the system-provided date and timer text components, watchOS automatically adjusts the label’s presentation to fit the available space. The system also updates the content without further input from your app.

Consider using date and timer components in complications. For design guidance, see [Complications](../System%20experiences/Complications.md); for developer guidance, see [Text](https://developer.apple.com/documentation/swiftui/text).

## Resources

#### Related

[Text fields](../Selection%20and%20input/Text%20fields.md)

[Text views](../Content/Text%20views.md)

#### Developer documentation

[Label](https://developer.apple.com/documentation/swiftui/label) — SwiftUI

[Text](https://developer.apple.com/documentation/swiftui/text) — SwiftUI

[UILabel](https://developer.apple.com/documentation/uikit/uilabel) — UIKit

[NSTextField](https://developer.apple.com/documentation/appkit/nstextfield) — AppKit

## Change log

| Date | Changes |
| --- | --- |
| June 5, 2023 | Updated guidance to reflect changes in watchOS 10. |

---
*Source: [https://developer.apple.com/design/human-interface-guidelines/labels](https://developer.apple.com/design/human-interface-guidelines/labels)*
