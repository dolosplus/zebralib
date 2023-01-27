# zebra-capacitor

Zebra printer capacitor plugin library for iOS. Ionic Capacitor v3 wrapper with ZSDK_API. Support base64 PDF and regular Text printing.

Only tested with ZQ520 and ZQ521. Should work for all Zebra Bluetooth printers. Android is not yet supported at the moment unless someone wants to contribute to this repo. Contact me at [DOLOS+](http://dolosplus.com/contact.html)

## Install

```bash
npm install @dolosplus/zebra-capacitor
npx cap sync
```

## API

<docgen-index>

* [`connectPrinter(...)`](#connectprinter)
* [`printText(...)`](#printtext)
* [`printPDF(...)`](#printpdf)
* [`addListener('printerStatusChange', ...)`](#addlistenerprinterstatuschange)
* [Interfaces](#interfaces)
* [Type Aliases](#type-aliases)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### connectPrinter(...)

```typescript
connectPrinter(options: { config: string; }) => Promise<any>
```

| Param         | Type                             |
| ------------- | -------------------------------- |
| **`options`** | <code>{ config: string; }</code> |

**Returns:** <code>Promise&lt;any&gt;</code>

--------------------


### printText(...)

```typescript
printText(options: { text: string; }) => Promise<any>
```

| Param         | Type                           |
| ------------- | ------------------------------ |
| **`options`** | <code>{ text: string; }</code> |

**Returns:** <code>Promise&lt;any&gt;</code>

--------------------


### printPDF(...)

```typescript
printPDF(options: { base64: string; size?: { x: number; y: number; width: number; height: number; }; }) => Promise<any>
```

| Param         | Type                                                                                              |
| ------------- | ------------------------------------------------------------------------------------------------- |
| **`options`** | <code>{ base64: string; size?: { x: number; y: number; width: number; height: number; }; }</code> |

**Returns:** <code>Promise&lt;any&gt;</code>

--------------------


### addListener('printerStatusChange', ...)

```typescript
addListener(eventName: 'printerStatusChange', listenerFunc: StateChangeListener) => Promise<PluginListenerHandle> & PluginListenerHandle
```

| Param              | Type                                                                |
| ------------------ | ------------------------------------------------------------------- |
| **`eventName`**    | <code>'printerStatusChange'</code>                                  |
| **`listenerFunc`** | <code><a href="#statechangelistener">StateChangeListener</a></code> |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt; & <a href="#pluginlistenerhandle">PluginListenerHandle</a></code>

--------------------


### Interfaces


#### PluginListenerHandle

| Prop         | Type                                      |
| ------------ | ----------------------------------------- |
| **`remove`** | <code>() =&gt; Promise&lt;void&gt;</code> |


#### ConnectState

| Prop           | Type                 | Description                       | Since |
| -------------- | -------------------- | --------------------------------- | ----- |
| **`isActive`** | <code>boolean</code> | Whether the app is active or not. | 1.0.0 |


### Type Aliases


#### StateChangeListener

<code>(state: <a href="#connectstate">ConnectState</a>): void</code>

</docgen-api>
