[Human Interface Guidelines](../README.md) › [Getting started](../Getting%20started.md) › **Designing for games**

# Designing for games

*When people play your game on an Apple device, they dive into the world you designed while relying on the platform features they love.*

> **Note**
>
> Updated guidance for touch-based controls and Game Center.

![A stylized representation of a game controller shown on top of a grid. The image is overlaid with rectangular and circular grid lines and is tinted green to subtly reflect the green in the original six-color Apple logo.](https://developer.apple.com/tutorials/images/com.apple.HIG/platforms-games-intro@2x.png)

As you create or adapt a game for Apple platforms, learn how to integrate the fundamental platform characteristics and patterns that help your game feel at home on all Apple devices. To learn what makes each platform unique, see [Designing for iOS](Designing%20for%20iOS.md), [Designing for iPadOS](Designing%20for%20iPadOS.md), [Designing for macOS](Designing%20for%20macOS.md), [Designing for tvOS](Designing%20for%20tvOS.md), [Designing for visionOS](Designing%20for%20visionOS.md), and [Designing for watchOS](Designing%20for%20watchOS.md). For developer guidance, see [Games Pathway](https://developer.apple.com/games/pathway/).

## Jump into gameplay

**Let people play as soon as installation completes.**  You don’t want a player’s first experience with your game to be waiting for a lengthy download. Include as much playable content as you can in your game’s initial installation while keeping the download time to 30 minutes or less. Download additional content in the background. For guidance, see [Loading](../Patterns/Loading.md).

**Provide great default settings.**  People appreciate being able to start playing without first having to change a lot of settings. Use information about a player’s device to choose the best defaults for your game, such as the device resolution that makes your graphics look great, automatic recognition of paired accessories and game controllers, and the player’s accessibility settings. Also, make sure your game supports the platform’s most common interaction methods. For guidance, see [Settings](../Patterns/Settings.md).

**Teach through play.**  Players often learn better when they discover new information and mechanics in the context of your game’s world, so it can work well to integrate configuration and onboarding flows into a playable tutorial that engages people quickly and helps them feel successful right away. If you also have a written tutorial, consider offering it as a resource players can refer to when they have questions instead of making it a prerequisite for gameplay. For guidance, see [Onboarding](../Patterns/Onboarding.md).

**Defer requests until the right time.**  You don’t want to bombard people with too many requests before they start playing, but if your game uses certain sensors on an Apple device or personalizes gameplay by accessing data like hand-tracking, you must first get the player’s permission (for guidance, see [Privacy](../Foundations/Privacy.md)). To help people understand why you’re making such a request, integrate it into the scenario that requires the data. For example, you could ask permission to track a player’s hands between an initial cutscene and the first time they can use their hands to control the action. Also, make sure people spend quality time with your game before you ask them for a rating or review (for guidance, see [Ratings and reviews](../Patterns/Ratings%20and%20reviews.md)).

<table>
<tr>
<td valign="top">

<a href="../Patterns/Launching.md"><img src="https://developer.apple.com/tutorials/images/com.apple.HIG/patterns-launching-thumbnail@2x.png" alt="A sketch of a square containing an arrow pointing to the upper-right corner, suggesting a transition to a new state. The image is tinted orange to subtly reflect the orange in the original six-color Apple logo." width="100%"></a>  
**[Launching](../Patterns/Launching.md)**  
A streamlined launch experience helps people start using your app or game immediately.

</td>
<td valign="top">

<a href="../Patterns/Onboarding.md"><img src="https://developer.apple.com/tutorials/images/com.apple.HIG/patterns-onboarding-thumbnail@2x.png" alt="A sketch of a waving hand, suggesting a gesture of welcoming. The image is tinted orange to subtly reflect the orange in the original six-color Apple logo." width="100%"></a>  
**[Onboarding](../Patterns/Onboarding.md)**  
Onboarding can help people get a quick start using your app or game.

</td>
<td valign="top">

<a href="../Patterns/Loading.md"><img src="https://developer.apple.com/tutorials/images/com.apple.HIG/patterns-loading-thumbnail@2x.png" alt="A sketch of a spinning indeterminate activity indicator, suggesting data loading. The image is tinted orange to subtly reflect the orange in the original six-color Apple logo." width="100%"></a>  
**[Loading](../Patterns/Loading.md)**  
The best content-loading experience finishes before people become aware of it.

</td>
</tr>
</table>

## Look stunning on every display

**Make sure text is always legible.**  When game text is hard to read, people can struggle to follow the narrative, understand important instructions and information, and stay engaged in the experience. To keep text comfortably legible on each device, ensure that it contrasts well with the background and uses at least the recommended minimum text size in each platform. For guidance, see [Typography](../Foundations/Typography.md); for developer guidance, see [Adapting your game interface for smaller screens](https://developer.apple.com/documentation/metal/adapting-your-game-interface-for-smaller-screens).

| Platform | Default text size | Minimum text size |
| --- | --- | --- |
| iOS, iPadOS | 17 pt | 11 pt |
| macOS | 13 pt | 10 pt |
| tvOS | 29 pt | 23 pt |
| visionOS | 17 pt | 12 pt |
| watchOS | 16 pt | 12 pt |

**Make sure buttons are always easy to use.**  Buttons that are too small or too close together can frustrate players and make gameplay less fun. Each platform defines a recommended minimum button size based on its default interaction method. For example, buttons in iOS must be at least 44x44 pt to accommodate touch interaction. For guidance, see [Buttons](../Components/Menus%20and%20actions/Buttons.md).

| Platform | Default button size | Minimum button size |
| --- | --- | --- |
| iOS, iPadOS | 44x44 pt | 28x28 pt |
| macOS | 28x28 pt | 20x20 pt |
| tvOS | 66x66 pt | 56x56 pt |
| visionOS | 60x60 pt | 28x28 pt |
| watchOS | 44x44 pt | 28x28 pt |

**Prefer resolution-independent textures and graphics.**  If creating resolution-independent assets isn’t possible, match the resolution of your game to the resolution of the device. In visionOS, prefer vector-based art that can continue to look good when the system dynamically scales it as people view it from different distances and angles. For guidance, see [Images](../Foundations/Images.md).

**Integrate device features into your layout.**  For example, a device may have rounded corners or a camera housing that can affect parts of your interface. To help your game look at home on each device, accommodate such features during layout, relying on platform-provided safe areas when possible (for developer guidance, see [Positioning content relative to the safe area](https://developer.apple.com/documentation/uikit/positioning-content-relative-to-the-safe-area)). For guidance, see [Layout](../Foundations/Layout.md); for templates that include safe-area guides, see [Apple Design Resources](https://developer.apple.com/design/resources/).

**Make sure in-game menus adapt to different aspect ratios.**  Games need to look good and behave well at various aspect ratios, such as 16:10, 19.5:9, and 4:3. In particular, in-game menus need to remain legible and easy to use on every device — and, if you support them, in both orientations on iPhone and iPad — without obscuring other content. To help ensure your in-game menus render correctly, consider using dynamic layouts that rely on relative constraints to adjust to different contexts. Avoid fixed layouts as much as possible, and aim to create a custom, device-specific layout only when necessary. For guidance, see [In-game menus](https://developer.apple.com/design/human-interface-guidelines/menus#In-game-menus).

**Design for the full-screen experience.**  People often enjoy playing a game in a distraction-free, full-screen context. In macOS, iOS, and iPadOS, full-screen mode lets people hide other apps and parts of the system UI; in visionOS, a game running in a Full Space can completely surround people, transporting them somewhere else. For guidance, see [Going full screen](../Patterns/Going%20full%20screen.md).

<table>
<tr>
<td valign="top">

<a href="../Foundations/Layout.md"><img src="https://developer.apple.com/tutorials/images/com.apple.HIG/foundations-layout-thumbnail@2x.png" alt="A sketch of a small rectangle in the upper-left quadrant of a larger rectangle, suggesting the position of a user interface element within a window. The image is overlaid with rectangular and circular grid lines and is tinted yellow to subtly reflect the yellow in the original six-color Apple logo." width="100%"></a>  
**[Layout](../Foundations/Layout.md)**  
A consistent layout that adapts to various contexts makes your experience more approachable and helps people enjoy their favorite apps and games on all their devices.

</td>
<td valign="top">

<a href="../Foundations/Typography.md"><img src="https://developer.apple.com/tutorials/images/com.apple.HIG/foundations-typography-thumbnail@2x.png" alt="A sketch of a small letter A to the left of a large letter A, suggesting the use of typography to convey hierarchical information. The image is tinted yellow to subtly reflect the yellow in the original six-color Apple logo." width="100%"></a>  
**[Typography](../Foundations/Typography.md)**  
Your typographic choices can help you display legible text, convey an information hierarchy, communicate important content, and express your brand or style.

</td>
<td valign="top">

<a href="../Patterns/Going%20full%20screen.md"><img src="https://developer.apple.com/tutorials/images/com.apple.HIG/patterns-going-full-screen-thumbnail@2x.png" alt="A sketch of two outward-pointing arrows arranged in a vertical line extending from the upper-left to the bottom-right, suggesting expansion. The image is tinted orange to subtly reflect the orange in the original six-color Apple logo." width="100%"></a>  
**[Going full screen](../Patterns/Going%20full%20screen.md)**  
iPhone, iPad, and Mac offer full-screen modes that let people expand a window to fill the screen, hiding system controls and providing a distraction-free environment.

</td>
</tr>
</table>

## Enable intuitive interactions

**Support each platform’s default interaction method.**  For example, people generally use touch to play games on iPhone; on a Mac, players tend to expect keyboard and mouse or trackpad support; and in a visionOS game, people expect to use their eyes and hands while making indirect and direct gestures. As you work to ensure that your game supports each platform’s default interaction method, pay special attention to control sizing and menu behavior, especially when bringing your game from a pointer-based context to a touch-based one.

| Platform | Default interaction methods | Additional interaction methods |
| --- | --- | --- |
| iOS | Touch | Game controller |
| iPadOS | Touch | Game controller, keyboard, mouse, trackpad, Apple Pencil |
| macOS | Keyboard, mouse, trackpad | Game controller |
| tvOS | Remote | Game controller, keyboard, mouse, trackpad |
| visionOS | Touch | Game controller, keyboard, mouse, trackpad, spatial game controller |
| watchOS | Touch | – |

**Support physical game controllers, while also giving people alternatives.**  Every platform except watchOS supports physical game controllers. Although the presence of a game controller makes it straightforward to port controls from an existing game and handle complex control mappings, recognize that not every player can use a physical game controller. To make your game available to as many players as possible, also offer alternative ways to interact with your game. For guidance, see [Physical controllers](https://developer.apple.com/design/human-interface-guidelines/game-controls#Physical-controllers).

**Offer touch-based game controls that embrace the touchscreen experience on iPhone and iPad.**  In iOS and iPadOS, your game can allow players to interact directly with game elements, and to control the game using virtual controls that appear on top of your game content. For design guidance, see [Touch controls](https://developer.apple.com/design/human-interface-guidelines/game-controls#Touch-controls).

<table>
<tr>
<td valign="top">

<a href="../Inputs/Game%20controls.md"><img src="https://developer.apple.com/tutorials/images/com.apple.HIG/inputs-game-controls-thumbnail@2x.png" alt="A sketch of a D-pad control from a game controller, suggesting gameplay. The image is tinted purple to subtly reflect the purple in the original six-color Apple logo." width="100%"></a>  
**[Game controls](../Inputs/Game%20controls.md)**  
Precise, intuitive game controls enhance gameplay and can increase a player’s immersion in the game.

</td>
<td valign="top">

<a href="../Inputs/Gestures.md"><img src="https://developer.apple.com/tutorials/images/com.apple.HIG/inputs-gestures-thumbnail@2x.png" alt="A sketch of a pointing hand swiping in a curved motion toward the right, suggesting touch interaction with a device. The image is tinted purple to subtly reflect the purple in the original six-color Apple logo." width="100%"></a>  
**[Gestures](../Inputs/Gestures.md)**  
A gesture is a physical motion that a person uses to directly affect an object in an app or game on their device.

</td>
<td valign="top">

<a href="../Inputs/Pointing%20devices.md"><img src="https://developer.apple.com/tutorials/images/com.apple.HIG/inputs-pointing-devices-thumbnail@2x.png" alt="A sketch of an arrow-shaped pointer, suggesting use of a mouse or trackpad. The image is tinted purple to subtly reflect the purple in the original six-color Apple logo." width="100%"></a>  
**[Pointing devices](../Inputs/Pointing%20devices.md)**  
People can use a pointing device like a trackpad or mouse to navigate the interface and initiate actions.

</td>
</tr>
</table>

## Welcome everyone

**Prioritize perceivability.**  Make sure people can perceive your game’s content whether they use sight, hearing, or touch. For example, avoid relying solely on color to convey an important detail, or providing a cutscene that doesn’t include descriptive subtitles or offer other ways to read the content. For specific guidance, see:

- Text sizes
- Color and effects
- Motion
- Interactions
- Buttons

**Help players personalize their experience.**  Players have a variety of preferences and abilities that influence their interactions with your game. Because there’s no universal configuration that suits everyone, give players the ability to customize parameters like type size, game control mapping, motion intensity, and sound balance. You can take advantage of built-in [Apple accessibility technologies](https://developer.apple.com/accessibility/) to support accessibility personalizations, whether you’re using system frameworks or [Unity plug-ins](https://github.com/Apple/UnityPlugins).

**Give players the tools they need to represent themselves.**  If your game encourages players to create avatars or supply names or descriptions, support the spectrum of self-identity and provide options that represent as many human characteristics as possible.

**Avoid stereotypes in your stories and characters.**  Ask yourself whether you’re depicting game characters and scenarios in a way that perpetuates real-life stereotypes. For example, does your game depict enemies as having a certain race, gender, or cultural heritage? Review your game to uncover and remove biases and stereotypes and — if references to real-life cultures and languages are necessary — be sure they’re respectful.

<table>
<tr>
<td valign="top">

<a href="../Foundations/Accessibility.md"><img src="https://developer.apple.com/tutorials/images/com.apple.HIG/foundations-accessibility-thumbnail@2x.png" alt="A sketch of the Accessibility icon. The image is tinted yellow to subtly reflect the yellow in the original six-color Apple logo." width="100%"></a>  
**[Accessibility](../Foundations/Accessibility.md)**  
Accessible user interfaces empower everyone to have a great experience with your app or game.

</td>
<td valign="top">

<a href="../Foundations/Inclusion.md"><img src="https://developer.apple.com/tutorials/images/com.apple.HIG/foundations-inclusion-thumbnail@2x.png" alt="A sketch of two people, suggesting inclusion. The image is tinted yellow to subtly reflect the yellow in the original six-color Apple logo." width="100%"></a>  
**[Inclusion](../Foundations/Inclusion.md)**  
Inclusive apps and games put people first by prioritizing respectful communication and presenting content and functionality in ways that everyone can access and understand.

</td>
</tr>
</table>

## Adopt Apple technologies

**Integrate Game Center to help players discover your game across their devices and connect with their friends.**  [Game Center](https://developer.apple.com/game-center/) is Apple’s social gaming network, available on all platforms. Game Center lets players keep track of their progress and achievements and allows you to set up leaderboards, challenges, and multiplayer activities in your game. For design guidance, see [Game Center](../Technologies/Game%20Center.md); for developer guidance, see [GameKit](https://developer.apple.com/documentation/gamekit).

**Let players pick up their game on any of their devices.**  People often have a single iCloud account that they use across multiple Apple devices. When you support [GameSave](https://developer.apple.com/documentation/gamesave), you can help people save their game state and start back up exactly where they left off on a different device.

**Support haptics to help players feel the action.**  When you adopt Core Haptics, you can compose and play custom haptic patterns, optionally combined with custom audio content. Core Haptics is available in iOS, iPadOS, tvOS, and visionOS, and supported on many game controllers. For guidance, see [Playing haptics](../Patterns/Playing%20haptics.md); for developer guidance, see [Core Haptics](https://developer.apple.com/documentation/corehaptics) and [Playing Haptics on Game Controllers](https://developer.apple.com/documentation/corehaptics/playing-haptics-on-game-controllers).

**Use Spatial Audio to immerse players in your game’s soundscape.**  Providing multichannel audio can help your game’s audio adapt automatically to the current device, enabling an immersive Spatial Audio experience where supported. For guidance, see [visionOS](https://developer.apple.com/design/human-interface-guidelines/playing-audio#visionOS); for developer guidance, see [Explore Spatial Audio](https://developer.apple.com/news/?id=fakg1z5b).

**Take advantage of Apple technologies to enable unique gameplay mechanics.**  For example, you can integrate technologies like augmented reality, machine learning, and [HealthKit](https://developer.apple.com/documentation/healthkit), and request access to location data and functionality like camera and microphone. For a full list of Apple technologies, features, and services, see [Technologies](../Technologies.md).

<table>
<tr>
<td valign="top">

<a href="../Technologies/Game%20Center.md"><img src="https://developer.apple.com/tutorials/images/com.apple.HIG/technologies-game-center-thumbnail@2x.png" alt="A sketch of the Game Center icon. The image is tinted blue to subtly reflect the blue in the original six-color Apple logo." width="100%"></a>  
**[Game Center](../Technologies/Game%20Center.md)**  
Game Center is Apple’s social gaming network, which lets players track their progress and connect with friends across Apple platforms, and boosts the discovery of your game across players’ devices.

</td>
<td valign="top">

<a href="../Technologies/iCloud.md"><img src="https://developer.apple.com/tutorials/images/com.apple.HIG/technologies-icloud-thumbnail@2x.png" alt="A sketch of the iCloud icon. The image is tinted blue to subtly reflect the blue in the original six-color Apple logo." width="100%"></a>  
**[iCloud](../Technologies/iCloud.md)**  
iCloud is a service that lets people seamlessly access the content they care about — photos, videos, documents, and more — from any device, without performing explicit synchronization.

</td>
<td valign="top">

<a href="../Technologies/In-app%20purchase.md"><img src="https://developer.apple.com/tutorials/images/com.apple.HIG/technologies-in-app-purchase-thumbnail@2x.png" alt="A sketch of an add button, suggesting the purchase of additional digital assets within an app. The image is tinted blue to subtly reflect the blue in the original six-color Apple logo." width="100%"></a>  
**[In-app purchase](../Technologies/In-app%20purchase.md)**  
People can use in-app purchase to pay for virtual goods — like premium content, digital goods, and subscriptions — securely within your app.

</td>
</tr>
</table>

## Resources

#### Related

[Game Center](../Technologies/Game%20Center.md)

[Game controls](../Inputs/Game%20controls.md)

#### Developer documentation

[Games Pathway](https://developer.apple.com/games/get-started/)

[Create games for Apple platforms](https://developer.apple.com/games/)

#### Videos

<table>
<tr>
<td valign="top">

<a href="https://developer.apple.com/videos/play/wwdc2026/356"><img src="https://devimages-cdn.apple.com/wwdc-services/images/9B2E82C5-4DDF-4B9A-9459-328D8E297696/47BE2F6C-78E8-4AF4-9318-9FF3EDB1A049/10906_wide_250x141_2x.jpg" alt="47be2f6c 78e8 4af4 9318 9ff3edb1a049" width="100%"></a>  
**[Bringing Cyberpunk 2077 to Mac](https://developer.apple.com/videos/play/wwdc2026/356)**  
Go behind the scenes and learn from CD PROJEKT RED how Cyberpunk 2077 came to Mac, setting a new standard for AAA gaming on macOS. Explore how the team leveraged Apple’s robust hardware, software, and development tools to bring this high-fidelity experience to life. Learn how you can apply similar techniques to your games. Find out how the innovative ‘For this Mac’ preset automatically optimizes graphical settings to balance visual fidelity and frame rate across the Mac lineup.

</td>
<td valign="top">

<a href="https://developer.apple.com/videos/play/wwdc2026/252"><img src="https://devimages-cdn.apple.com/wwdc-services/images/9B2E82C5-4DDF-4B9A-9459-328D8E297696/DABC6BCF-5A35-4B9C-9217-200576EAD404/10775_wide_250x141_2x.jpg" alt="dabc6bcf 5a35 4b9c 9217 200576ead404" width="100%"></a>  
**[Design no-code games with Reality Composer Pro 3](https://developer.apple.com/videos/play/wwdc2026/252)**  
Discover how you can use ScriptGraph in Reality Composer Pro 3 to create no-code 3D content for your apps and games. Learn how to take advantage of visual nodes to build animations, create interactive moments, and incorporate SwiftUI elements to add speech bubbles and other UI to your experience.

</td>
<td valign="top">

<a href="https://developer.apple.com/videos/play/wwdc2025/209"><img src="https://devimages-cdn.apple.com/wwdc-services/images/3055294D-836B-4513-B7B0-0BC5666246B0/6C097D36-BE91-4B04-854A-E6264DA86F15/9890_wide_250x141_2x.jpg" alt="6c097d36 be91 4b04 854a e6264da86f15" width="100%"></a>  
**[Level up your games](https://developer.apple.com/videos/play/wwdc2025/209)**  
Learn how to make your games shine on the unified gaming platform. We’ll give you a map of the technologies you can use to level up your game and further improve your player experience. Get an overview of the fundamental tools essential to build, debug, and profile your game.

</td>
</tr>
</table>

## Change log

| Date | Changes |
| --- | --- |
| June 9, 2025 | Updated guidance for touch-based controls and Game Center. |
| June 10, 2024 | New page. |

---
*Source: [https://developer.apple.com/design/human-interface-guidelines/designing-for-games](https://developer.apple.com/design/human-interface-guidelines/designing-for-games)*
