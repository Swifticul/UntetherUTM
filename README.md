<img src="./appicon.png" alt="Whitelist Icon" width="50" height="50">

# UntetherUTM

UntetherUTM is a modified UTM client that replaces standard UTM code with sbatupoc or SideJITServer to enable untethered JIT activation when installed using SideStore.

## Requirements

- iOS 14.0 to iOS 16.x (iOS 17.0 or later for SJS builds)
- SideStore (latest pull-request build)

## Important Notes

- SideStore might not always activate JIT when using sbatupoc; this happens infrequently. If it occurs, you can either restart the app or tap the + icon to request JIT activation from the SideStore servers (or on SJS builds, from SideJITServer).

## Building the IPA

- You can find pre-built IPAs in the "Releases" tab.
- To build the IPA from source, follow the instructions in the [iOS Development Guide](Documentation/iOSDevelopment.md).
