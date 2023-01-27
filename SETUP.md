# Setting up Capacitor Plugin with Zebra SDK

1. Add libZSDK_API.a to Plugin project
2. Add all the required Zebra's header files



## Integration with Ionic App
1. Add section below to Info.plist
```
<key>UISupportedExternalAccessoryProtocols</key>
	<array>
		<string>com.zebra.rawport</string>
	</array>
```

## Reference:

[LINK_OS - libZSDK_API](https://www.zebra.com/us/en/support-downloads/printer-software/link-os-multiplatform-sdk.html)

[Sample Code Repo](https://github.com/ZebraDevs/LinkOS-iOS-Samples)

[API Doc](file:///Applications/link_os_sdk/iOS/v1.5.1049/doc/html/index.html)
