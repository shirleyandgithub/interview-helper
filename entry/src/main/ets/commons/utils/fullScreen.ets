import { window } from '@kit.ArkUI'

class FullScreen {
  // 需求：
  // 1. 提供 enable disable 开启和关闭沉浸式
  // 2. 提供安全区的高度，顶部安全区 + 底部安全区
  // 注意：需要的 context 在 appStorage 共享一个
  async enable () {
    const ctx = AppStorage.get<Context>('context');
    if (ctx) {
      const win = await window.getLastWindow(ctx)
      win.setWindowLayoutFullScreen(true)
      // 共享安全区高度
      const topArea = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM).topRect
      AppStorage.setOrCreate('topHeight', px2vp(topArea.height))
      const bottomArea = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR).bottomRect
      AppStorage.setOrCreate('bottomHeight', px2vp(bottomArea.height))
    }
  }

  async disable () {
    const ctx = AppStorage.get<Context>('context');
    if (ctx) {
      const win = await window.getLastWindow(ctx)
      win.setWindowLayoutFullScreen(false)
      AppStorage.setOrCreate('topHeight', 0)
      AppStorage.setOrCreate('bottomHeight', 0)
    }
  }
}

export const fullScreen = new FullScreen()

