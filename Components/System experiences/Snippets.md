[Human Interface Guidelines](../../README.md) › [Components](../../Components.md) › [System experiences](../System%20experiences.md) › **Snippets**

# Snippets

*When someone performs a task with Siri or an App Shortcut, a snippet shows the result or asks for confirmation.*

> **Note**
>
> New page.

![A stylized representation of a snippet, showing a proposed date and time for a Calendar event along with a Done button. The image is tinted red to subtly reflect the red in the original six-color Apple logo.](https://docs-assets.developer.apple.com/published/6ad132520b34a702ece093b94927051b/components-snippets-intro%402x.png)

Snippets are compact views that appear in response to an action that someone takes using [Siri](../../Technologies/Siri.md), Spotlight, or the Shortcuts app.

You can present a snippet related to one of your app’s actions by including it with an [App Intents](https://developer.apple.com/documentation/AppIntents) that you design to meet the specific needs of a task. For example, you might design a snippet for checking the weather forecast or updating progress toward a daily goal.

There are two snippet types: confirmation and result. A *confirmation* snippet lets people confirm or cancel an action, and may include options that affect the result. By contrast, a *result* snippet provides information — possibly as the outcome of a confirmation — that doesn’t require further action. An app intent that displays a snippet always shows a result, while the confirmation step is optional.

![A partial screenshot showing a confirmation snippet on iPhone. The snippet includes an order summary at the top, with a Cancel button and an Order button at the bottom for the person to cancel or confirm the order.](https://docs-assets.developer.apple.com/published/2d19b56685a1e57b2483c2b47ec7e1a4/snippets-confirmation-type%402x.png)  
*A confirmation snippet requires additional input to proceed.*

![A partial screenshot showing a result snippet on iPhone. The snippet includes an order status and shipping date at the top, with a Done button at the bottom for the person to dismiss the snippet.](https://docs-assets.developer.apple.com/published/de34735d3c828ea0c260d77239dbff2b/snippets-result-type%402x.png)  
*A result snippet provides information without requiring further action.*

For developer guidance, see [Displaying static and interactive snippets](https://developer.apple.com/documentation/AppIntents/displaying-static-and-interactive-snippets).

## Anatomy

A snippet consists of the following elements:

- **Dialogue.** The app intent dialogue that Siri speaks to communicate the snippet’s information. The system includes the dialogue text by default and places it above the custom view.
- **Custom view.** A view that visually communicates the snippet’s information. A custom view can include one or more buttons for modifying the content of the snippet, getting more information, or taking another action.
- **System-provided button(s).** A confirmation snippet includes two system-provided buttons under the custom view: a secondary Cancel button and a primary button with a customizable label. A result snippet includes a single Done button that dismisses the view.

![An illustration of a snippet's anatomy. The dialogue appears at the top of the snippet. The custom view appears in the middle, with a maximum height of 400 pt. Two system-provided buttons appear at the bottom: the secondary button on the left and the primary button on the right.](https://docs-assets.developer.apple.com/published/df14ef0c2c59b7e766df870afb9d8758/snippets-custom-view-layout%402x.png)

## Best practices

**Ensure legibility.** Check for sufficient contrast between the snippet’s custom content and the system-provided background in both light and dark appearances, and keep consistent margins for the content within the view. This clarifies the layout and helps people interpret the snippet quickly and reliably.

**Keep content concise.** Snippets exist to facilitate lightweight, quick interactions, so it’s important to keep their content short and easily legible. To ensure all content is visible, create custom views that are no taller than the 400-point maximum height. When considering the amount of text to include, be mindful that fonts draw at various sizes based on a person’s preferred text size setting. For a result snippet, if you need to provide more detail, deep-link to the content in your app instead of including it in the custom view.

**Choose a descriptive label for a confirmation snippet’s primary button.** You can choose an appropriate label from among those that the [ConfirmationActionName](https://developer.apple.com/documentation/AppIntents/ConfirmationActionName), or you can supply a custom label. For example, when designing a snippet to order coffee, labeling the primary button Order is clearer than labeling it OK or Proceed. If you don’t specify a label, the system default is Continue.

**Communicate a snippet’s purpose visually.** Don’t rely on showing the dialogue text to convey a snippet’s purpose. While the spoken app intent dialogue is essential for interactions when someone isn’t looking at the screen, prefer to omit it from a snippet’s visual representation and use the custom view to convey its information instead.

![An illustration of a result snippet from Calendar that shows details for an upcoming event. The dialogue at the top repeats the information from the custom view, so that the event title, date, time, and participants are included in both places.](https://docs-assets.developer.apple.com/published/2d055a948721aaf6be601d70fec1cadb/snippet-response-heavy-dialogue-incorrect%402x.png)

![An X in a circle to indicate incorrect usage.](https://docs-assets.developer.apple.com/published/209f6f0fc8ad99d9bf59e12d82d06584/crossout%402x.png)

![An illustration of a result snippet from Calendar that shows details for an upcoming event. The snippet omits the dialogue from the top and includes the event title, date, time, and participants in the custom view only.](https://docs-assets.developer.apple.com/published/412ebcb089ee21de3cb91f9b492720ca/snippet-response-light-dialogue-correct%402x.png)

![A checkmark in a circle to indicate correct usage.](https://docs-assets.developer.apple.com/published/88662da92338267bb64cd2275c84e484/checkmark%402x.png)

## Platform considerations

*No additional considerations for iOS, iPadOS, or macOS. Not supported in tvOS, visionOS, or watchOS.*

## Resources

#### Related

[Siri](../../Technologies/Siri.md)

[App Shortcuts](App%20Shortcuts.md)

[Live Activities](Live%20Activities.md)

#### Developer documentation

[App Intents](https://developer.apple.com/documentation/AppIntents)

#### Videos

- [Design interactive snippets](https://developer.apple.com/videos/play/wwdc2025/281) — Snippets are compact views invoked from App Intents that display information from your app. Now, snippets can allow your app to bring even more capability to Siri, Spotlight, and the Shortcuts app by including buttons and stateful information that offer additional interactivity as part of an intent. In this session, you’ll learn best practices for designing snippets, including guidance on layout, typography, interaction, and intent types.

## Change log

| Date | Changes |
| --- | --- |
| June 8, 2026 | New page. |

---
*Source: [https://developer.apple.com/design/human-interface-guidelines/snippets](https://developer.apple.com/design/human-interface-guidelines/snippets)*
