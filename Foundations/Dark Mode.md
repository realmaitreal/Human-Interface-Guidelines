[Human Interface Guidelines](../README.md) › [Foundations](../Foundations.md) › **Dark Mode**

# Dark Mode

*Dark Mode is a systemwide appearance setting that uses a dark color palette to provide a comfortable viewing experience tailored for low-light environments.*

> **Note**
>
> Added art contrasting the light and dark appearances.

![A sketch of concentric circles with half-filled areas, suggesting the presence of light and dark. The image is overlaid with rectangular and circular grid lines and is tinted yellow to subtly reflect the yellow in the original six-color Apple logo.](https://developer.apple.com/tutorials/images/com.apple.HIG/foundations-dark-mode-intro@2x.png)

In iOS, iPadOS, macOS, and tvOS, people often choose Dark Mode as their default interface style, and they generally expect all apps and games to respect their preference. In Dark Mode, the system uses a dark color palette for all screens, views, menus, and controls, and may also use greater perceptual contrast to make foreground content stand out against the darker backgrounds.

## Best practices

**Avoid offering an app-specific appearance setting.** An app-specific appearance mode option creates more work for people because they have to adjust more than one setting to get the appearance they want. Worse, they may think your app is broken because it doesn’t respond to their systemwide appearance choice.

**Ensure that your app looks good in both appearance modes.** In addition to using one mode or the other, people can choose the Auto appearance setting, which switches between the light and dark appearances as conditions change throughout the day, potentially while your app is running.

**Test your content to make sure that it remains comfortably legible in both appearance modes.** For example, in Dark Mode with Increase Contrast and Reduce Transparency turned on (both separately and together), you may find places where dark text is less legible when it’s on a dark background. You might also find that turning on Increase Contrast in Dark Mode can result in reduced visual contrast between dark text and a dark background. Although people with strong vision might still be able to read lower contrast text, such text could be illegible for many. For guidance, see [Accessibility](Accessibility.md).

**In rare cases, consider using only a dark appearance in the interface.** For example, it can make sense for an app that supports immersive media viewing to use a permanently dark appearance that lets the UI recede and helps people focus on the media.

![A screenshot of the Stocks app on iPhone in its standard dark-only appearance, showing the Apple Inc. stock in detail. The view includes a summary of the current stock price along with a graph of its performance over the past year.](https://developer.apple.com/tutorials/images/com.apple.HIG/dark-mode-stocks-app-dark-only-mode@2x.png)  
*The Stocks app uses a dark-only appearance*

## Dark Mode colors

The color palette in Dark Mode includes dimmer background colors and brighter foreground colors. It’s important to realize that these colors aren’t necessarily inversions of their light counterparts: while many colors are inverted, some are not. For more information, see [Specifications](https://developer.apple.com/design/human-interface-guidelines/color#Specifications).

**Embrace colors that adapt to the current appearance.** Semantic colors (like [labelColor](https://developer.apple.com/documentation/appkit/nscolor/labelcolor) and [controlColor](https://developer.apple.com/documentation/appkit/nscolor/controlcolor) in macOS or [separator](https://developer.apple.com/documentation/uikit/uicolor/separator) in iOS and iPadOS) automatically adapt to the current appearance. When you need a custom color, add a Color Set asset to your app’s asset catalog in Xcode, and specify the bright and dim variants of the color. Avoid using hard-coded color values or colors that don’t adapt.

<table>
<tr>
<td>

![An illustration of a square with a light background and four color swatches representing system colors in the light appearance.](https://developer.apple.com/tutorials/images/com.apple.HIG/dark-mode-system-colors-light@2x.png)  
*System colors in the light appearance*

</td>
<td>

![An illustration of a square with a dark background and four color swatches representing system colors in the dark appearance.](https://developer.apple.com/tutorials/images/com.apple.HIG/dark-mode-system-colors-dark@2x.png)  
*System colors in the dark appearance*

</td>
</tr>
</table>

**Aim for sufficient color contrast in all appearances.** Using system-defined colors can help you achieve a good contrast ratio between your foreground and background content. At a minimum, make sure the contrast ratio between colors is no lower than 4.5:1. For custom foreground and background colors, strive for a contrast ratio of 7:1, especially in small text. This ratio ensures that your foreground content stands out from the background, and helps your content meet recommended accessibility guidelines.

**Soften the color of white backgrounds.** If you display a content image that includes a white background, consider slightly darkening the image to prevent the background from glowing in the surrounding Dark Mode context.

### Icons and images

The system uses [SF Symbols](SF%20Symbols.md) (which automatically adapt to Dark Mode) and full-color images that are optimized for both the light and dark appearances.

**Use SF Symbols wherever possible.** Symbols work well in both appearance modes when you use dynamic colors to tint them or when you add vibrancy. For guidance, see [Color](Color.md).

**Design separate interface icons for the light and dark appearances if necessary.** For example, an icon that depicts a full moon might need a subtle dark outline to contrast well with a light background, but need no outline when it displays on a dark background. Similarly, an icon that represents a drop of oil might need a slight border to make the edge visible against a dark background.

<table>
<tr>
<td>

![An illustration of a black droplet icon against a light background.](https://developer.apple.com/tutorials/images/com.apple.HIG/dark-mode-icon-in-light-mode@2x.png)  
*Icon in the light appearance with no border*

</td>
<td>

![An illustration of a black droplet icon against a dark background. The icon has a white border to distinguish it from the similar surrounding color.](https://developer.apple.com/tutorials/images/com.apple.HIG/dark-mode-icon-in-dark-mode@2x.png)  
*Icon in the dark appearance with border for better contrast*

</td>
</tr>
</table>

**Make sure full-color images and icons look good in both appearances.** Use the same asset if it looks good in both the light and dark appearances. If an asset looks good in only one mode, modify the asset or create separate light and dark assets. Use asset catalogs to combine your assets into a single named image.

<table>
<tr>
<td>

![An illustration of two people sitting at a restaurant table done in a simple, abstract style. The illustration has a light background and its details are clearly visible.](https://developer.apple.com/tutorials/images/com.apple.HIG/dark-mode-illustration-in-light-mode@2x.png)  
*Illustration on a light background*

</td>
<td>

![An illustration of two people sitting at a restaurant table done in a simple, abstract style. The illustration has a dark background, and the darker portions of the image are hard to distinguish from the background.](https://developer.apple.com/tutorials/images/com.apple.HIG/dark-mode-illustration-in-dark-mode-incorrect@2x.png)  
*On a dark background, the same illustration has poor contrast and many details are lost*

</td>
<td>

![An illustration of two people sitting at a restaurant table done in a simple, abstract style. The illustration has a dark background, and its color values are adjusted to be clearly visible in contrast to the background.](https://developer.apple.com/tutorials/images/com.apple.HIG/dark-mode-illustration-in-dark-mode-correct@2x.png)  
*Illustration adjusted for better contrast on a dark background*

</td>
</tr>
</table>

### Text

The system uses vibrancy and increased contrast to maintain the legibility of text on darker backgrounds.

**Use the system-provided label colors for labels.** The primary, secondary, tertiary, and quaternary label colors adapt automatically to the light and dark appearances.

<table>
<tr>
<td>

![An illustration of a button in the light appearance with dark primary label text.](https://developer.apple.com/tutorials/images/com.apple.HIG/dark-mode-label-in-light-mode@2x.png)  
*Primary label in the light appearance*

</td>
<td>

![An illustration of a button in the dark appearance with light secondary label text.](https://developer.apple.com/tutorials/images/com.apple.HIG/dark-mode-label-in-dark-mode@2x.png)  
*Secondary label in the dark appearance*

</td>
</tr>
</table>

**Use system views to draw text fields and text views.** System views and controls make your app’s text look good on all backgrounds, adjusting automatically for the presence or absence of vibrancy. When possible, use a system-provided view to display text instead of drawing the text yourself.

## Platform considerations

*No additional considerations for tvOS. Dark Mode isn’t supported in visionOS or watchOS.*

### iOS, iPadOS

In Dark Mode, the system uses two sets of background colors — called *base* and *elevated* — to enhance the perception of depth when one dark interface is layered above another. The base colors are dimmer, making background interfaces appear to recede, and the elevated colors are brighter, making foreground interfaces appear to advance.

<table>
<tr>
<td>

![A diagram that shows a stack of 4 terms on top of a black background. The term at the top shows the most contrast with the background and the term at the bottom shows the least.](https://developer.apple.com/tutorials/images/com.apple.HIG/base-with-four-semantic-colors@2x.png)  
*Base*

</td>
<td>

![A diagram that shows a stack of 4 terms on top of a nearly black background. The term at the top shows the most contrast with the background and the term at the bottom shows the least.](https://developer.apple.com/tutorials/images/com.apple.HIG/elevated-with-four-semantic-colors@2x.png)  
*Elevated*

</td>
<td>

![A diagram that shows a stack of 4 terms on top of a white background. The term at the top shows the most contrast with the background and the term at the bottom shows the least.](https://developer.apple.com/tutorials/images/com.apple.HIG/light-with-four-semantic-colors@2x.png)  
*Light*

</td>
</tr>
</table>

**Prefer the system background colors.** Dark Mode is dynamic, which means that the background color automatically changes from base to elevated when an interface is in the foreground, such as a popover or modal sheet. The system also uses the elevated background color to provide visual separation between apps in a multitasking environment and between windows in a multiple-window context. Using a custom background color can make it harder for people to perceive these system-provided visual distinctions.

### macOS

When people choose the graphite accent color in General settings, macOS causes window backgrounds to pick up color from the current desktop picture. The result — called *desktop tinting* — is a subtle effect that helps windows blend more harmoniously with their surrounding content.

**Include some transparency in custom component backgrounds when appropriate.** Transparency lets your components pick up color from the window background when desktop tinting is active, creating a visual harmony that can persist even when the desktop picture changes. To help achieve this harmony, add transparency only to a custom component that has a visible background or bezel, and only when the component is in a neutral state, such as state that doesn’t use color. You don’t want to add transparency when the component is in a state that uses color, because doing so can cause the component’s color to fluctuate when the window background adjusts to a different location on the desktop or when the desktop picture changes.

## Resources

#### Related

[Color](Color.md)

[Materials](Materials.md)

[Typography](Typography.md)

#### Videos

<table>
<tr>
<td valign="top">

<a href="https://developer.apple.com/videos/play/wwdc2025/219"><img src="https://devimages-cdn.apple.com/wwdc-services/images/3055294D-836B-4513-B7B0-0BC5666246B0/5CD0E251-424E-490F-89CF-1E64848209A6/9910_wide_250x141_2x.jpg" alt="5cd0e251 424e 490f 89cf 1e64848209a6" width="64"></a>  
**[Meet Liquid Glass](https://developer.apple.com/videos/play/wwdc2025/219)**  
Liquid Glass unifies Apple platform design language while providing a more dynamic and expressive user experience. Get to know the design principles of Liquid Glass, explore its core optical and physical properties, and learn where to use it and why.

</td>
<td valign="top">

<a href="https://developer.apple.com/videos/play/wwdc2019/214"><img src="https://devimages-cdn.apple.com/wwdc-services/images/48/174747D6-8723-4194-A932-7765179F1108/2949_wide_250x141_2x.jpg" alt="174747d6 8723 4194 a932 7765179f1108" width="64"></a>  
**[Implementing Dark Mode on iOS](https://developer.apple.com/videos/play/wwdc2019/214)**  
Hear from the UIKit engineering team about the principles and concepts that anchor Dark Mode on iOS. Get introduced to the principles of enhancing your app with this new appearance using dynamic colors and images, and add an experience that people are sure to love.

</td>
</tr>
</table>

## Change log

| Date | Changes |
| --- | --- |
| August 6, 2024 | Added art contrasting the light and dark appearances. |

---
*Source: [https://developer.apple.com/design/human-interface-guidelines/dark-mode](https://developer.apple.com/design/human-interface-guidelines/dark-mode)*
