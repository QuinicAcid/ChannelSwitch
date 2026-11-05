# ChannelSwitch

Switch chat channels with the Tab key. No mouse needed.

Open the chat box, press **Tab**, and the channel changes. Press **Shift+Tab** to go backward. It works even when you've already started typing, and your text stays put.

## Features

- Cycles through Say, Party, Raid, Instance, Guild, and Yell
- Includes your numbered channels (General, Trade, LocalDefense, and any others you've joined) if they're ticked in your chat window's channel settings
- Skips channels you can't use right now, such as Raid when you're solo
- Keeps your typed text when you switch
- Leaves slash-command autocomplete and whisper-target cycling alone, so those still work with Tab
- No settings, no saved variables, no slash commands

## Customizing

To change the order of the built-in channels, edit the `ORDER` list at the top of `ChannelSwitch.lua`.

## Compatibility

Built and tested for WoW: Forever (Interface 16001). Forever is new and its addon API is still changing, so please report anything that breaks after a patch.

## Feedback

Found a bug or have an idea? Leave a comment on the project page. When reporting a problem, include your game version, any other chat addons you run, and the error text from BugSack if there is one.

## License

MIT. Made by QuinicAcid.

---

### Changelog

**1.0.0**
- First release
- Tab / Shift+Tab cycles chat channels
- Supports typed text, numbered channels, and group-aware channel skipping
