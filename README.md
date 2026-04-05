<div align="center">

<img width="128" alt="AppIcon" src="https://user-images.githubusercontent.com/43297314/212650409-e9fd08dd-17d7-4036-b067-53930a6ae286.png"/>

# UpGood

A lightweight macOS menu bar app to upload files to the cloud for free.

Powered by [Litterbox](https://litterbox.catbox.moe) (temporary, up to 1 GB) and [Catbox](https://catbox.moe) (permanent, up to 200 MB).

</div>

## Features

- **Temporary uploads** via Litterbox — expires after 1h, 12h, 24h, or 72h (up to 1 GB)
- **Permanent uploads** via Catbox — files stay forever (up to 200 MB)
- Menu bar icon for quick access
- One-click copy of the uploaded file URL
- No account required

## Installation

Clone and open in Xcode:

```bash
git clone https://github.com/Aayush9029/UpGood.git
open UpGood/UpGood.xcodeproj
```

Build and run (requires macOS 13+).

## How it works

1. Click the menu bar icon or open the app window
2. Select a file to upload
3. Choose temporary (Litterbox) or permanent (Catbox) mode
4. Click "Upload Now"
5. Copy the returned URL

## License

MIT
