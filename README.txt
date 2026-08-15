================================================================================
  EQSounds v1.1
  Classic EverQuest UI sounds for World of Warcraft 3.3.5a
================================================================================

  by DapperDyl


--------------------------------------------------------------------------------
  WHAT IS IT
--------------------------------------------------------------------------------

  A lightweight, standalone addon that plays authentic EverQuest UI
  sounds in a 3.3.5a client. No UI suite required.


--------------------------------------------------------------------------------
  SOUNDS
--------------------------------------------------------------------------------

  ding     Level up                         (Titanium levelup.wav)
  bag      B key / open-close bags / bank   (itemclth.wav)
  loot     Loot window open / take item     (buyitem.wav)
  equip    Equip or unequip gear            (wearclth.wav)

  Autoloot: loot sound plays only once per corpse/chest.
  Multi-bag open (B): bag sound is throttled to a single play.


--------------------------------------------------------------------------------
  VOLUME (new in v1.1)
--------------------------------------------------------------------------------

  Stock 3.3.5 has no per-file volume API for PlaySoundFile, so three
  baked in loudness tiers ship as flat files under Sounds\:

    low   -12 dB   (default)
    med   -8 dB
    high  -4 dB

  /eqsounds vol low
  /eqsounds vol med
  /eqsounds vol high

  Setting is saved. Startup chat line explains the default and command.

  Optional .mp3 previews of each tier are included for listening outside
  the game (the client uses .ogg only).


--------------------------------------------------------------------------------
  COMMANDS
--------------------------------------------------------------------------------

  /eqsounds help
  /eqsounds status
  /eqsounds ding|bag|loot|equip          test a sound
  /eqsounds ding on|off   (etc.)         toggle a sound
  /eqsounds vol low|med|high             set volume tier
  /eqding  or  /ding                     test the level-up ding


--------------------------------------------------------------------------------
  INSTALL
--------------------------------------------------------------------------------

  1. Extract EQSounds into Interface\AddOns\
  2. Path should be: Interface\AddOns\EQSounds\
  3. /reload

  Compatible with stock UI, ElvUI, and other packs.
  If something conflicts, reach out @DapperDyl Discord or IGN - Cheesus.


--------------------------------------------------------------------------------
  CHANGELOG
--------------------------------------------------------------------------------

  v1.1
    - Added low / med / high volume tiers (baked .ogg files)
    - Default volume is low so SFX are not overbearing at low master volume
    - /eqsounds vol low|med|high (alias: volume)
    - Startup chat line explains default volume and how to change it
    - Flat Sounds\ layout (eqding_low.ogg etc.) for 3.3.5 path compatibility
    - Optional .mp3 previews for listening outside the client

  v1.0
    - Initial release: ding, bag/bank, loot (autoloot-safe), equip
    - /eqsounds and /ding commands
    - Toggles and status
    - Audio from EverQuest Titanium (snd2.pfs)


--------------------------------------------------------------------------------
  CREDITS
--------------------------------------------------------------------------------

  Written by DapperDyl
  Audio from EverQuest Titanium (snd2.pfs)

  GitHub: https://github.com/dapperdyl/EQSounds

================================================================================
