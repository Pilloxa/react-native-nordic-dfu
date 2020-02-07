declare module 'react-native-nordic-dfu' {
  export class NordicDFU {
    static startDFU({
      deviceAddress,
      deviceName,
      filePath,
      alternativeAdvertisingNameEnabled
    }: {
      deviceAddress: string;
      deviceName?: string;
      filePath: string | null;
      alternativeAdvertisingNameEnabled?: boolean;
    }): Promise<string>;
  }

  export interface IDfuUpdate {
    percent?: number;
    currentPart?: number;
    partsTotal?: number;
    avgSpeed?: number;
    speed?: number;
    state?: string;
  }

  export class DFUEmitter {
    static addListener(
      name: 'DFUProgress' | 'DFUStateChanged',
      handler: (update: IDfuUpdate) => void
    ): void;

    static removeAllListeners(name: 'DFUProgress' | 'DFUStateChanged'): void;
  }
}
