import { router } from '@kit.ArkUI';
import { HcNavBar } from '../commons/components/HcNavBar';
import { auth } from '../commons/utils/auth';
import { ColorModeKey } from '../commons/utils/theme';
import { User } from '../models';
import { SettingsThemeDialog } from '../views/Settings/SettingsThemeDialog';
import { bundleManager, common, ConfigurationConstant, Want } from '@kit.AbilityKit';
import { statistics } from '@kit.NetworkKit';
import { fileIo, storageStatistics } from '@kit.CoreFileKit';

export interface Tool {
  icon?: ResourceStr
  name: string
  value?: string
  onClick?: () => void,
  radius?: 0 | 1 | 2
}

@Entry
@Component
struct SettingsPage {
  @StorageProp(ColorModeKey) colorMode: ConfigurationConstant.ColorMode =
    ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT
  @State cache: string = '0MB'
  @State version: string = ''

  aboutToAppear(): void {
    this.getVersion()
  }

  async getVersion() {
    const info = await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION)
    this.version = 'V' + info.versionName
  }

  onPageShow() {
    this.calcCache()
  }

  async calcCache() {
    const result = await storageStatistics.getCurrentBundleStats()
    this.cache = (result.cacheSize / (1000 * 1000)).toFixed(2) + 'MB'
  }

  async clearCache() {
    // 1. hap的缓存
    const ctx = getContext(this)
    const hapCacheDir = ctx.cacheDir
    const ctxExist = fileIo.accessSync(hapCacheDir)
    if (ctxExist) {
      fileIo.rmdirSync(hapCacheDir)
    }
    // 2. 应用缓存
    const appCtx = ctx.getApplicationContext()
    const appCacheDir = appCtx.cacheDir
    const appCtxExist = fileIo.accessSync(appCacheDir)
    if (appCtxExist) {
      fileIo.rmdirSync(appCacheDir)
    }

    this.calcCache()
  }

  @Builder
  toolsBuilder(tool: Tool) {
    Row() {
      if (tool.icon) {
        Image(tool.icon)
          .width(16)
          .aspectRatio(1)
          .margin({ right: 12 })
      }
      Text(tool.name)
        .fontSize(16)
      Blank()
      if (tool.value) {
        Text(tool.value)
          .fontSize(14)
          .fontColor($r('app.color.common_gray_01'))
          .margin({ right: 10 })
      }
      Image($r('sys.media.ohos_ic_public_arrow_right'))
        .width(18)
        .aspectRatio(1)
        .fillColor($r('app.color.common_gray_01'))
    }
    .height(50)
    .width('100%')
    .backgroundColor($r('app.color.white'))
    .padding({ left: 16, right: 10 })
    .borderRadius({
      topLeft: tool.radius === 1 ? 8 : 0,
      topRight: tool.radius === 1 ? 8 : 0,
      bottomLeft: tool.radius === 2 ? 8 : 0,
      bottomRight: tool.radius === 2 ? 8 : 0
    })
    .onClick(() => {
      tool.onClick && tool.onClick()
    })
  }

  themeDialog = new CustomDialogController({
    builder: SettingsThemeDialog(),
    customStyle: true,
    alignment: DialogAlignment.Bottom
  })

  build() {
    Column() {
      HcNavBar({ title: '设置', showRightIcon: false, showBorder: true })
      Column({ space: 0.5 }) {
        Blank()
          .height(15)
        this.toolsBuilder({
          name: '编辑资料', radius: 1, onClick: () => {
            auth.checkAuth({
              url: 'pages/ProfilePage'
            })
          }
        })
        this.toolsBuilder({ name: '账号设置', radius: 2 })
        Blank()
          .height(15)
        this.toolsBuilder({
          name: '消息推送', radius: 1, onClick: () => {
            let want: Want = {
              bundleName: 'com.huawei.hmos.settings',
              abilityName: 'com.huawei.hmos.settings.MainAbility',
              // 什么页面参考表格
              uri: 'application_info_entry',
              parameters: {
                pushParams: 'xyz.zhousg.interview_success'
              }
            };
            const context = getContext(this) as common.UIAbilityContext
            context.startAbility(want)
          }
        })
        this.toolsBuilder({
          name: '深色模式',
          value: this.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK ? '已开启' : '已关闭',
          radius: 1,
          onClick: () => {
            // 设置主题
            this.themeDialog.open()
          }
        })
        this.toolsBuilder({
          name: '清除应用缓存', value: this.cache, onClick: () => {
            // 清除缓存
            this.clearCache()
          }
        })
        this.toolsBuilder({ name: '当前版本', value: this.version, radius: 2 })
        Blank()
          .height(15)
        Text('退出账号')
          .height(50)
          .fontColor($r('app.color.common_main_color'))
          .opacity(0.6)
          .onClick(async () => {
            auth.setUser({} as User)
            router.back()
          })
      }
      .layoutWeight(1)
      .padding({ right: 15, left: 15 })
      .backgroundColor($r('app.color.common_gray_bg'))
    }
  }
}