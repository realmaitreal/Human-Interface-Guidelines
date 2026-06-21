[Human Interface Guidelines](../../README.md) › [Components](../../Components.md) › [Menus and actions](../Menus%20and%20actions.md) › **Pop-up buttons**

# Pop-up buttons

*A pop-up button displays a menu of mutually exclusive options.*

> **Note**
>
> Added artwork.

![A stylized representation of a pop-up button displaying a set of options. The image is tinted red to subtly reflect the red in the original six-color Apple logo.](https://docs-assets.developer.apple.com/published/6b9dc6a6527fa5413fee7ecc2828dbab/components-pop-up-button-intro%402x.png)

After people choose an item from a pop-up button’s menu, the menu closes, and the button can update its content to indicate the current selection.

![A screenshot of Calendar on iPhone, with a new calendar event open for editing. The editing screen contains controls for setting the details of the event, including its start and end dates, travel time, repeat interval, calendar, invitees, alert options, and attachments.](https://docs-assets.developer.apple.com/published/519951a89c3c840e87eca8c5760f4d90/pop-up-button-closed%402x.png)

![A screenshot of Calendar on iPhone, with a new calendar event open for editing. A pop-up button menu emerges from the Repeat button, with options for choosing a repeat interval from a list of preset options, or creating a custom one.](https://docs-assets.developer.apple.com/published/61386d60280871ab2649bc5b2020aab5/pop-up-button-open%402x.png)

## Best practices

**Use a pop-up button to present a flat list of mutually exclusive options or states.** A pop-up button helps people make a choice that affects their content or the surrounding view. Use a [pull-down button](Pull-down%20buttons.md) instead if you need to:

- Offer a list of actions
- Let people select multiple items
- Include a submenu

**Provide a useful default selection.** A pop-up button can update its content to identify the current selection, but if people haven’t made a selection yet, it shows the default item you specify. When possible, make the default selection an item that most people are likely to want.

**Give people a way to predict a pop-up button’s options without opening it.** For example, you can use an introductory label or a button label that describes the button’s effect, giving context to the options.

**Consider using a pop-up button when space is limited and you don’t need to display all options all the time.** Pop-up buttons are a space-efficient way to present a wide array of choices.

**If necessary, include a Custom option in a pop-up button’s menu to provide additional items that are useful in some situations.** Offering a Custom option can help you avoid cluttering the interface with items or controls that people need only occasionally. You can also display explanatory text below the list to help people understand how the options work.

## Platform considerations

*No additional considerations for iOS, macOS, or visionOS. Not supported in tvOS or watchOS.*

### iPadOS

**Within a popover or modal view, consider using a pop-up button instead of a disclosure indicator to present multiple options for a list item.** For example, people can quickly choose an option from the pop-up button’s menu without navigating to a detail view. Consider using a pop-up button in this scenario when you have a fairly small, well-defined set of options that work well in a menu.

## Resources

#### Related

[Pull-down buttons](Pull-down%20buttons.md)

[Buttons](Buttons.md)

[Menus](Menus.md)

#### Developer documentation

[MenuPickerStyle](https://developer.apple.com/documentation/SwiftUI/MenuPickerStyle)  — SwiftUI

[changesSelectionAsPrimaryAction](https://developer.apple.com/documentation/UIKit/UIButton/changesSelectionAsPrimaryAction) — UIKit

[NSPopUpButton](https://developer.apple.com/documentation/AppKit/NSPopUpButton) — AppKit

## Change log

| Date | Changes |
| --- | --- |
| October 24, 2023 | Added artwork. |
| September 14, 2022 | Added a guideline on using a pop-up button in a popover or modal view in iPadOS. |

---
*Source: [https://developer.apple.com/design/human-interface-guidelines/pop-up-buttons](https://developer.apple.com/design/human-interface-guidelines/pop-up-buttons)*
