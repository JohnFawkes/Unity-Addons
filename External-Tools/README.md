# External Tools

Addon where external (not already included in unity) tools can be added. Typical use for this will be binaries.

Place arm and x86 compiled binaries into their respective folders inside tools directory and unity will load them/add them to path automatically so you can call them like any other binary (no need to specify path)

Place other cpu architecture independent tools into the other folder and unity will load them/add them to path automatically so you can call them like any other binary (no need to specify path)

Note that you may compress the tools folder into a tar.xz to save space
