import { HcNavBar } from '../commons/components/HcNavBar'
import { resourceManager } from '@kit.LocalizationKit'
import { util } from '@kit.ArkTS'
import { logger } from '../commons/utils/logger'
import { webview } from '@kit.ArkWeb'
import { promptAction } from '@kit.ArkUI'
import { WordDialog } from '../views/Word/WordDialog'


export interface WordItem {
  zh: string
  en: string
  code: string
}

type Words = Record<string, WordItem[]>

@Entry
@Component
struct WordPage {
  @State wordKey: string = ''
  words: Words = {}
  @State showTypeSheet: boolean = false
  scroller = new Scroller()
  webController = new webview.WebviewController()
  @State showCodeSheet: boolean = false
  @State currentCode: string = ''
  @State currentEn: string = ''
  @State currentZh: string = ''

  aboutToAppear(): void {
    this.initWords()
  }

  async initWords() {
    const ctx = getContext(this)
    const data = ctx.resourceManager.getRawFileContentSync('word.json')
    const textDecoder = util.TextDecoder.create()
    const json = textDecoder.decodeToString(data)
    this.words = JSON.parse(json) as Words
    // 默认实现第一个分类
    this.wordKey = Object.keys(this.words)[0]
  }

  dialog = new CustomDialogController({
    builder: WordDialog({ en: this.currentEn, zh: this.currentZh }),
    customStyle: true,
    alignment: DialogAlignment.Center
  })

  @Builder
  TypeSheetBuilder () {
    Column() {
      Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap }) {
        ForEach(Object.keys(this.words), (key: string) => {
          Button() {
            Text(key)
              .fontSize(14)
              .fontColor(key === this.wordKey ? $r('app.color.common_green') : $r('app.color.common_gray_01'))
          }
          .backgroundColor($r('app.color.common_gray_bg'))
          .padding({ top: 6, right: 12, bottom: 6, left: 12 })
          .margin({ right: 12, bottom: 12 })
          .onClick(() => {
            this.wordKey = key
            this.showTypeSheet = false

            // 滚动到顶
            this.scroller.scrollTo({ xOffset: 0, yOffset: 0 })
          })
        })
      }
    }
    .padding({ left: 16, right: 16, top: 8, bottom: 34 })
  }

  @Builder
  CodeSheetBuilder() {
    Column() {
      Web({ src: $rawfile('word.html'), controller: this.webController })
        .width('100%')
        .height(400)
        .backgroundColor($r('app.color.common_gray_bg'))
        .onPageEnd(() => {
          this.webController.runJavaScript(`writeHtml(\`${this.currentCode}\`)`)
        })
    }
    .padding({ left: 16, right: 16, top: 8, bottom: 34 })
  }

  build() {
    Column() {
      HcNavBar({ title: '常用单词', showRightIcon: false })
      Row() {
        Column({ space: 4 }) {
          Text('开发常用词汇')
          Text(`共 ${this.words[this.wordKey].length} 个单词`)
            .fontSize(12)
            .fontColor($r('app.color.common_gray_03'))
        }
        .alignItems(HorizontalAlign.Start)

        Row() {
          Text(this.wordKey)
            .fontSize(12)
            .fontColor($r('app.color.common_gray_01'))
          Image($r('sys.media.ohos_ic_public_arrow_down'))
            .width(16)
            .aspectRatio(1)
            .fillColor($r('app.color.common_gray_01'))
        }
        .onClick(() => {
          this.showTypeSheet = true
        })
        .bindSheet($$this.showTypeSheet, this.TypeSheetBuilder(), {
          title: { title: '选择阶段' },
          backgroundColor: $r('app.color.white'),
          height: 400
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding(16)
      .border({ width: { top: 0.5 }, color: $r('app.color.common_gray_bg') })

      Divider()
        .strokeWidth(8)
        .color($r('app.color.common_gray_bg'))

      List({ scroller: this.scroller }) {
        ForEach(this.words[this.wordKey], (item: WordItem) => {

          ListItem() {
            Row({ space: 6 }) {
              Image($r('sys.media.ohos_ic_public_sound'))
                .width(20)
                .aspectRatio(1)
                .alignSelf(ItemAlign.Start)
                .fillColor($r('app.color.common_gray_03'))
                .onClick(() => {
                  this.currentEn = item.en
                  this.currentZh = item.zh
                  this.dialog.open()
                })
              Column({ space: 10 }) {
                Text(item.en)
                  .fontWeight(FontWeight.Bold)
                Text(item.zh)
                  .fontSize(14)
                  .fontColor($r('app.color.common_gray_03'))
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              Row() {
                Text('详细代码')
                  .fontSize(12)
                  .fontColor(item.code ? $r('app.color.common_gray_01') : '#ddd')
                Image($r('sys.media.ohos_ic_public_arrow_right'))
                  .width(16)
                  .aspectRatio(1)
                  .fillColor(item.code ? $r('app.color.common_gray_01') : '#ddd')
              }
              .alignSelf(ItemAlign.End)
              .onClick(() => {
                this.currentCode = item.code
                if (this.currentCode) {
                  this.showCodeSheet = true
                } else {
                  promptAction.showToast({ message: '暂无代码' })
                }
              })
            }
            .padding(16)
          }
        })
      }
      .divider({
        strokeWidth: 0.5,
        color: $r('app.color.common_gray_bg')
      })
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .bindSheet($$this.showCodeSheet, this.CodeSheetBuilder(), {
      detents: [ SheetSize.FIT_CONTENT ], // 随内容撑开
      backgroundColor: $r('app.color.white'),
      title: { title: '详细代码' }
    })
  }
}