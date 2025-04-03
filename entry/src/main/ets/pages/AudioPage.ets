import { Permissions } from '@kit.AbilityKit'
import { permission } from '../commons/utils/permission'
import { promptAction, router } from '@kit.ArkUI'
import { AudioView } from '../views/Audio/AudioView'

@Entry
@Component
struct AudioPage {
  aboutToAppear(): void {
    this.requestPermission()
  }

  async requestPermission() {
    // 未授权不允许使用功能
    try {
      // 用户授权
      const permissionList: Permissions[] = ['ohos.permission.MICROPHONE']
      const flag = await permission.formUser(permissionList)
      if (flag) return
      // 用户引导
      const result = await promptAction.showDialog({
        title: '温馨提示',
        message: '未授权使用麦克风将无法使用该面试录音功能，是否前往设置进行授权？',
        buttons: [
          { text: '离开', color: $r('app.color.common_gray_01') },
          { text: '去授权', color: $r('app.color.black') }
        ]
      })
      if (result.index === 1) {
        // 二次授权
        const flag2 = await permission.onSetting(permissionList)
        if (flag2) return
      }
      router.back()
    } catch (e) {
      router.back()
    }
  }

  build() {
    Column(){
      // 面试录音视图
      AudioView()
    }
  }
}