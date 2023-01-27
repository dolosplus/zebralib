import { WebPlugin } from '@capacitor/core';

import type { ZebraLibPlugin } from './definitions';

export class ZebraLibWeb extends WebPlugin implements ZebraLibPlugin {

  // async echo(options: { value: string }): Promise<{ value: string }> {
  //   console.log('ECHO', options);
  //   return options;
  // }

  async connectPrinter(options: { config: string }): Promise<any>{
    return options;
  }

  async printText(options: { text: string }): Promise<any>{
    console.log('ECHO', options);
    return options;
  }

  async printPDF(options: { base64: string, size?: {x:number,y:number,width:number, height:number}}): Promise<any> {
    console.log('Web Zebra Print is not supported', options);
    return options;
  }

}
