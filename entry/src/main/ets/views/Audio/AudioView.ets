import { HcNavBar } from "../../commons/components/HcNavBar"
import { audioDB, InterviewAudioItem } from "../../commons/utils/audioDB"
import { auth } from "../../commons/utils/auth"
import { AudioItemComp } from "./AudioItemComp"
import { AudioRecordComp } from "./AudioRecordComp"
import { InputDialog } from "./InputDialog"
import { fileIo } from "@kit.CoreFileKit"
import { AudioPlayer } from "./AudioPlayer"

@Component
export struct AudioView {
  @State list: InterviewAudioItem[] = []

  aboutToAppear(): void {
    audioDB.initDB()
      .then(() => {
        this.getList()
      })
  }

  async getList() {
    const user = auth.getUser()
    const list = await audioDB.query(user.id)
    this.list = list
  }

  @State currentItem: InterviewAudioItem = {} as InterviewAudioItem
  dialog = new CustomDialogController({
    builder: InputDialog({
      name: this.currentItem.name,
      onSubmit: async (newName) => {
        // 更新
        this.dialog.close()
        this.currentItem.name = newName
        await audioDB.update(this.currentItem)
        this.getList()
      }
    }),
    customStyle: true,
    alignment: DialogAlignment.Center
  })

  @Builder
  ListItemSwipeBuilder(item: InterviewAudioItem) {
    Row() {
      Text('编辑')
        .actionButton($r('app.color.common_blue'))
        .onClick(() => {
          // 弹窗编辑名称对话框
          this.currentItem = item
          this.dialog.open()
        })
      Text('删除')
        .actionButton('#FF0033')
        .onClick(async () => {
          if (item.id) {
            audioDB.delete(item.id)
            this.getList()
            // 磁盘中删除源文件
            fileIo.unlinkSync(item.path)
          }
        })
    }
    .height('100%')
  }

  @State show: boolean = false
  @Builder
  PlayerBuilder () {
    Column(){
      AudioPlayer({ item: this.currentItem })
    }
  }

  build() {
    Column() {
      HcNavBar({ title: '面试录音', showRightIcon: false })
      Column() {
        List() {
          ForEach(this.list, (item: InterviewAudioItem) => {
            ListItem() {
              AudioItemComp({
                item: item
              })
            }
            .swipeAction({
              end: this.ListItemSwipeBuilder(item)
            })
            .onClick(() => {
              this.currentItem = item
              this.show = true
            })
          })
        }
        .width('100%')
        .height('100%')
      }
      .width('100%')
      .layoutWeight(1)

      AudioRecordComp({
        onRecordEnd: async (item) => {
          await audioDB.insert(item)
          this.getList()
        }
      })
    }
    .width('100%')
    .height('100%')
    .bindContentCover($$this.show, this.PlayerBuilder())
  }
}

@Extend(Text)
function actionButton(color: ResourceColor) {
  .width(80)
  .aspectRatio(1)
  .backgroundColor(color)
  .textAlign(TextAlign.Center)
  .fontColor($r('app.color.white'))
}