import { HcNavBar } from '../commons/components/HcNavBar'
import { webview } from '@kit.ArkWeb'
import { router } from '@kit.ArkUI'

@Entry
@Component
struct WebPage {
  webController = new webview.WebviewController()
  @State src: string = ''
  @State title: string = ''

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, string>
    this.src = params.src
    this.title = params.title
  }

  build() {
    Column() {
      HcNavBar({ title: this.title, showRightIcon: false })
      Web({ src: this.src, controller: this.webController })
        .width('100%')
        .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
  }
}