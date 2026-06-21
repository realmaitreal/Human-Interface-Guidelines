[Human Interface Guidelines](../../README.md) › [Components](../../Components.md) › [Navigation and search](../Navigation%20and%20search.md) › **Token fields**

# Token fields

*A token field is a type of text field that can convert text into *tokens* that are easy to select and manipulate.*

![A stylized representation of a text field containing a person's name formatted as a token. The image is tinted red to subtly reflect the red in the original six-color Apple logo.](https://docs-assets.developer.apple.com/published/64977cb59922b6997ec41234d7539664/components-token-field-intro%402x.png)

For example, Mail uses token fields for the address fields in the compose window. As people enter recipients, Mail converts the text that represents each recipient’s name into a token. People can select these recipient tokens and drag to reorder them or move them into a different field.

You can configure a token field to present people with a list of suggestions as they enter text into the field. For example, Mail suggests recipients as people type in an address field. When people select a suggested recipient, Mail inserts the recipient into the field as a token.

![A partial screenshot of a Mail compose window in which tokens represent some recipients.](https://docs-assets.developer.apple.com/published/ab0f5c6dea336edb0c10cf09e33b05e3/token-fields-suggestion%402x.png)

An individual token can also include a contextual menu that offers information about the token or editing options. For example, a recipient token in Mail includes a contextual menu with commands for editing the recipient name, marking the recipient as a VIP, and viewing the recipient’s contact card, among others.

![A partial screenshot of a Mail compose window in which one recipient token reveals a menu of commands.](https://docs-assets.developer.apple.com/published/84d649e57814229dc2c7acb5fe5e230f/token-fields-contextual%402x.png)

Tokens can also represent search terms in some situations; for guidance, see [Search fields](Search%20fields.md).

## Best practices

**Add value with a context menu.** People often benefit from a [context menu](../Menus%20and%20actions/Context%20menus.md) with additional options or information about a token.

**Consider providing additional ways to convert text into tokens.** By default, text people enter turns into a token whenever they type a comma. You can specify additional shortcuts, such as pressing Return, that also invoke this action.

**Consider customizing the delay the system uses before showing suggested tokens.** By default, suggestions appear immediately. However, suggestions that appear too quickly may distract people while they’re typing. If your app suggests tokens, consider adjusting the delay to a comfortable level.

## Platform considerations

*Not supported in iOS, iPadOS, tvOS, visionOS, and watchOS.*

## Resources

#### Related

[Text fields](../Selection%20and%20input/Text%20fields.md)

[Search fields](Search%20fields.md)

[Context menus](../Menus%20and%20actions/Context%20menus.md)

#### Developer documentation

[NSTokenField](https://developer.apple.com/documentation/AppKit/NSTokenField) — AppKit

---
*Source: [https://developer.apple.com/design/human-interface-guidelines/token-fields](https://developer.apple.com/design/human-interface-guidelines/token-fields)*
