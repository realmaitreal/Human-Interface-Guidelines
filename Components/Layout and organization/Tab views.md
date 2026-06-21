[Human Interface Guidelines](../../README.md) › [Components](../../Components.md) › [Layout and organization](../Layout%20and%20organization.md) › **Tab views**

# Tab views

*A tab view presents multiple mutually exclusive panes of content in the same area, which people can switch between using a tabbed control.*

> **Note**
>
> Added guidance for using tab views in watchOS.

![A stylized representation of a view with three labeled tabs, the first of which is selected. The image is tinted red to subtly reflect the red in the original six-color Apple logo.](https://docs-assets.developer.apple.com/published/38512ae4515e58e5eefbddbd6a8ce7a9/components-tab-view-intro%402x.png)

## Best practices

**Use a tab view to present closely related areas of content.** The appearance of a tab view provides a strong visual indication of enclosure. People expect each tab to display content that is in some way similar or related to the content in the other tabs.

**Make sure the controls within a pane affect content only in the same pane.** Panes are mutually exclusive, so ensure they’re fully self-contained.

**Provide a label for each tab that describes the contents of its pane.** A good label helps people predict the contents of a pane before clicking or tapping its tab. In general, use nouns or short noun phrases for tab labels. A verb or short verb phrase may make sense in some contexts. Use title-style capitalization for tab labels.

**Avoid using a pop-up button to switch between tabs.** A tabbed control is efficient because it requires a single click or tap to make a selection, whereas a pop-up button requires two. A tabbed control also presents all choices onscreen at the same time, whereas people must click a pop-up button to see its choices. Note that a pop-up button can be a reasonable alternative in cases where there are too many panes of content to reasonably display with tabs.

**Avoid providing more than six tabs in a tab view.** Having more than six tabs can be overwhelming and create layout issues. If you need to present six or more tabs, consider another way to implement the interface. For example, you could instead present each tab as a view option in a pop-up button menu.

For developer guidance, see [NSTabView](https://developer.apple.com/documentation/AppKit/NSTabView).

## Anatomy

The tabbed control appears on the top edge of the content area. You can choose to hide the control, which is appropriate for an app that switches between panes programmatically.

![An illustration of a window in which a three-tab tabbed control is centered on the top edge of the content view.](https://docs-assets.developer.apple.com/published/05bb7fbc6365c3bab10db218644756c3/tab-views-top%402x.png)

When you hide the tabbed control, the content area can be borderless, bezeled, or bordered with a line. A borderless view can be solid or transparent.

**In general, inset a tab view by leaving a margin of window-body area on all sides of a tab view.** This layout looks clean and leaves room for additional controls that aren’t directly related to the contents of the tab view. You can extend a tab view to meet the window edges, but this layout is unusual.

## Platform considerations

*Not supported in iOS, iPadOS, tvOS, or visionOS.*

### iOS, iPadOS

For similar functionality, consider using a [segmented control](../Selection%20and%20input/Segmented%20controls.md) instead.

### watchOS

watchOS displays tab views using [page controls](../Presentation/Page%20controls.md). For developer guidance, see [TabView](https://developer.apple.com/documentation/SwiftUI/TabView).

![An illustration showing the page control next to the Digital Crown on Apple Watch. The current dot is enlarged, indicating that people can scroll through the current content, as well as scroll between pages.](https://docs-assets.developer.apple.com/published/10938a94cb663210f148e0fbce431e70/tab-view-watch-vertical%402x.png)

## Resources

#### Related

[Tab bars](../Navigation%20and%20search/Tab%20bars.md)

[Segmented controls](../Selection%20and%20input/Segmented%20controls.md)

#### Developer documentation

[TabView](https://developer.apple.com/documentation/SwiftUI/TabView) — SwiftUI

[NSTabView](https://developer.apple.com/documentation/AppKit/NSTabView) — AppKit

## Change log

| Date | Changes |
| --- | --- |
| June 5, 2023 | Added guidance for using tab views in watchOS. |

---
*Source: [https://developer.apple.com/design/human-interface-guidelines/tab-views](https://developer.apple.com/design/human-interface-guidelines/tab-views)*
