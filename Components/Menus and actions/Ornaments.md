[Human Interface Guidelines](../../README.md) › [Components](../../Components.md) › [Menus and actions](../Menus%20and%20actions.md) › **Ornaments**

# Ornaments

*In visionOS, an ornament presents controls and information related to a window, without crowding or obscuring the window’s contents.*

> **Note**
>
> Added guidance on using multiple ornaments.

![A stylized representation of an ornament at the bottom of a window shown on top of a grid that suggests the canvas of a design tool. The image is tinted red to subtly reflect the red in the original six-color Apple logo.](https://developer.apple.com/tutorials/images/com.apple.HIG/components-ornaments-intro@2x.png)

An ornament floats in a plane that’s parallel to its associated window and slightly in front of it along the z-axis. If the associated window moves, the ornament moves with it, maintaining its relative position; if the window’s contents scroll, the controls or information in the ornament remain unchanged.

Ornaments can appear on any edge of a window and can contain UI components like buttons, segmented controls, and other views. The system uses ornaments to create and manage components like [Toolbars](Toolbars.md), [Tab bars](../Navigation%20and%20search/Tab%20bars.md), and video playback controls; you can use an ornament to create a custom component.

## Best practices

**Consider using an ornament to present frequently needed controls or information in a consistent location that doesn’t clutter the window.** Because an ornament stays close to its window, people always know where to find it. For example, Music uses an ornament to offer Now Playing controls, ensuring that these controls remain in a predictable location that’s easy to find.

**In general, keep an ornament visible.** It can make sense to hide an ornament when people dive into a window’s content — for example, when they watch a video or view a photo — but in most cases, people appreciate having consistent access to an ornament’s controls.

**If you need to display multiple ornaments, prioritize the overall visual balance of the window.** Ornaments help elevate important actions, but they can sometimes distract from your content. When necessary, consider constraining the total number of ornaments to avoid increasing a window’s visual weight and making your app feel more complicated. If you decide to remove an ornament, you can relocate its elements into the main window.

**Aim to keep an ornament’s width the same or narrower than the width of the associated window.** If an ornament is wider than its window, it can interfere with a tab bar or other vertical content on the window’s side.

**Consider using borderless buttons in an ornament.** By default, an ornament’s background is [visionOS](https://developer.apple.com/design/human-interface-guidelines/materials#visionOS), so if you place a button directly on the background, it may not need a visible border. When people look at a borderless button in an ornament, the system automatically applies the hover effect to it (for guidance, see [Eyes](../../Inputs/Eyes.md)).

**Use system-provided toolbars and tab bars unless you need to create custom components.** In visionOS, toolbars and tab bars automatically appear as ornaments, so you don’t need to use an ornament to create these components. For developer guidance, see [Toolbars](https://developer.apple.com/documentation/swiftui/toolbars) and [TabView](https://developer.apple.com/documentation/swiftui/tabview).

## Platform considerations

*Not supported in iOS, iPadOS, macOS, tvOS, or watchOS.*

## Resources

#### Related

[Layout](../../Foundations/Layout.md)

[Toolbars](Toolbars.md)

#### Developer documentation

[ornament(visibility:attachmentAnchor:contentAlignment:ornament:)](https://developer.apple.com/documentation/swiftui/view/ornament(visibility:attachmentanchor:contentalignment:ornament:)) — SwiftUI

#### Videos

<table>
<tr>
<td valign="top">

<a href="https://developer.apple.com/videos/play/wwdc2023/10076"><img src="https://devimages-cdn.apple.com/wwdc-services/images/D35E0E85-CCB6-41A1-B227-7995ECD83ED5/38E4EE32-29B5-4478-B8B6-35B8ACA67B16/8130_wide_250x141_2x.jpg" alt="38e4ee32 29b5 4478 b8b6 35b8aca67b16" width="64"></a>  
**[Design for spatial user interfaces](https://developer.apple.com/videos/play/wwdc2023/10076)**  
Learn how to design great interfaces for spatial computing apps. We’ll share how your existing screen-based knowledge easily translates into creating great experiences for visionOS. Explore guidelines for UI components, materials, and typography and find out how you can design experiences that are familiar, legible, and easy to use.

</td>
</tr>
</table>

## Change log

| Date | Changes |
| --- | --- |
| February 2, 2024 | Added guidance on using multiple ornaments. |
| December 5, 2023 | Removed a statement about using ornaments to present supplementary items. |
| June 21, 2023 | New page. |

---
*Source: [https://developer.apple.com/design/human-interface-guidelines/ornaments](https://developer.apple.com/design/human-interface-guidelines/ornaments)*
