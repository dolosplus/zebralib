import type { PluginListenerHandle } from '@capacitor/core';

export interface ConnectState {
  /**
   * Whether the app is active or not.
   *
   * @since 1.0.0
   */
  isActive: boolean;
}

export type StateChangeListener = (state: ConnectState) => void;

export interface ZebraLibPlugin {
  //echo(options: { value: string }): Promise<{ value: string }>;
  connectPrinter(options: {config: string}): Promise<any>;
  printText(options: { text: string }): Promise<any>;
  printPDF(options: { base64: string, size?: {x:number,y:number,width:number, height:number} }): Promise<any>;
  addListener(
    eventName: 'printerStatusChange',
    listenerFunc: StateChangeListener,
  ): Promise<PluginListenerHandle> & PluginListenerHandle;

}
