import { common, ConfigurationConstant } from '@kit.AbilityKit'
import { logger } from './logger'

export const ColorModeKey = 'hc-color-mode'

class Theme {
  // 应用默认浅色
  initTheme() {
    PersistentStorage.persistProp<ConfigurationConstant.ColorMode>(ColorModeKey,
      ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT)
    // 设置应用目前的颜色模式
    const mode = AppStorage.get<ConfigurationConstant.ColorMode>(ColorModeKey)
    this.setTheme(mode!)
    // 监听系统主题变化更新isDark ( 跟随系统，系统切换主题，需要监听 )
    const ctx = AppStorage.get<Context>('context')
    ctx?.getApplicationContext().on('environment', {
      onConfigurationUpdated: () => {
        // 获取应用颜色模式（共享给所有页面）
        AppStorage.setOrCreate<boolean>('isDark',
          (ctx as common.UIAbilityContext).config.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK)
      },
      onMemoryLevel: () => {

      }
    })
  }

  // 设置颜色模式
  setTheme(mode: ConfigurationConstant.ColorMode) {
    AppStorage.set<ConfigurationConstant.ColorMode>(ColorModeKey, mode)
    const ctx = AppStorage.get<Context>('context')
    ctx?.getApplicationContext().setColorMode(mode)
    // 获取应用颜色模式（共享给所有页面）
    AppStorage.setOrCreate<boolean>('isDark',
      (ctx as common.UIAbilityContext).config.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK)
  }

  // 跟随系统
  notSet() {
    this.setTheme(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET)
  }

  // 浅色
  setLight() {
    this.setTheme(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT)
  }

  // 深色
  setDark() {
    this.setTheme(ConfigurationConstant.ColorMode.COLOR_MODE_DARK)
  }
}

export const theme = new Theme()