<p align="center">
<font size=120>🤖</font>
</p>
<h1 align="center">XcodeScriptsKit</h1>
<pre align="center">
A set of scripts that helping you more easier to work with your swift project
</pre>

Features
---
- [x] automatic add build number for project
- [x] format swift source code in folder
- [x] generated image resource code
- [x] generated localization file code, support change language without relaunching

Installtion
---
`curl -fsSL https://raw.githubusercontent.com/CodeEagle/XcodeScriptsKit/master/install.sh | sh`

Usage
---

1. new run script in Xcode Build Phase before compile source
2. configure and paste code to it

			cd ~/bin/XcodeScriptsKit && ./script_manager.sh "1" "INFO_PLIST_PATH" "BUILD_NUMBER_PLIST_PATH" "GENERATED_CODE_PREFIX" "GENERATED_CODE_PATH" "IMAGE_ASSETS_PATH" "TO_FORMAT_CODE_PATH" "LANGUAGE_FILE_PATH"
3. build your project

Wiki
---
There has 8 parameters need to pass to the script

1. ENABLE_BUILD_NUMBER #"1" to enable, "0" to disable, if disable, 2 & 3 will be ignore
2. INFO_PLIST_PATH # "/path/to/info.plist"
3. BUILD_NUMBER_PLIST_PATH # "/path/to/save/build.plist"
4. GENERATED_CODE_PREFIX # prefix for generated code, such as "Re"
5. GENERATED_CODE_PATH # "/path/to/save/generatedCode"
6. IMAGE_ASSETS_PATH # "/path/to/*.xcassets"
7. TO_FORMAT_CODE_PATH # folder that needs code format
8. LANGUAGE_FILE_PATH # language file path,such as ".../zh-Hans.lproj/Localizable.strings"
