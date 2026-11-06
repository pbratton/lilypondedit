# lilypondedit

CMU term project working with LilyPond scores in Frescobaldi, using the Baroque Music Dataset for source material and FluidSynth for MIDI playback.

## Data

### Baroque Music Dataset (install to `./data/bmdataset`)

A musicologically curated collection of 391 baroque and early classical scores in LilyPond format (71 composers, 1700-1750 focus), with full musical metadata, MIDI renderings, and PDF scores/parts. Originates from transcriptions made by musicologists at [BaroqueMusic.it](https://baroquemusic.it) directly from manuscript sources.

Licensed under [CC BY-NC-ND 4.0](https://creativecommons.org/licenses/by-nc-nd/4.0/) — attribution required, noncommercial use only, no redistribution of modified material. See `data/bmdataset/README.md` (included with the dataset) for the full structure, metadata schema, and license text.

### Soundfont (install to `./assets/Sonatina_Symphonic_Orchestra.sf2`)

The [Sonatina Symphonic Orchestra](http://sso.mattiaswestlund.net/) soundfont by Mattias Westlund, in SF2 format as packaged by [Symphony2](https://musescore.org/en/user/49541) ([source](https://musescore.org/en/node/20378)). Licensed under Creative Commons Sampling Plus 1.0. See `assets/README` for known playback quirks.

## MIDI playback (FluidSynth + Frescobaldi, macOS)

This project uses Frescobaldi (https://www.frescobaldi.org/download.html) for manual LilyPond editing.  You can
wet up FluidSynth for audio playback of LilyPond scores:

Install FluidSynth via Homebrew:

```
brew install fluid-synth
```

Place the soundfont at `assets/Sonatina_Symphonic_Orchestra.sf2` (see above), then use the scripts in `scripts/`:

- `start-fluidsynth.sh` / `stop-fluidsynth.sh` — run FluidSynth manually in the background for a single session.
- `install-fluidsynth-service.sh` / `uninstall-fluidsynth-service.sh` — install/remove a per-user launchd agent so FluidSynth starts automatically at login and stops at logout, restarting itself if it crashes.

In Frescobaldi: **Edit > Preferences > MIDI settings**, select the FluidSynth virtual port as output.

Setup follows the [Frescobaldi wiki guide for MIDI playback on macOS](https://github.com/frescobaldi/frescobaldi/wiki/MIDI-playback-on-Mac-OS-X).
