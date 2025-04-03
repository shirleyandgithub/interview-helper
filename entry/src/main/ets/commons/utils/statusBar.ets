import { window } from '@kit.ArkUI'
import { logger } from './logger'

class StatusBar {
  // 需求：提供 setBar setDarkBar setLightBar
  async setBar(properties: window.SystemBarProperties) {
    try {
      const ctx = AppStorage.get<Context>('context')
      if (ctx) {
        const win = await window.getLastWindow(ctx)
        await win.setWindowSystemBarProperties(properties)
      }
    } catch (e) {
      logger.error('StatusBar setBar', JSON.stringify(e))
    }

  }

  setDarkBar() {
    this.setBar({ statusBarContentColor: '#000000' })
  }

  setLightBar() {
    this.setBar({ statusBarContentColor: '#ffffff' })
  }
}

export const statusBar = new StatusBar()