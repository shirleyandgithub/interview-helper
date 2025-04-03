import { HcSkeleton } from '../../commons/components/HcSkeleton'
import { HcSkeletonItem } from '../../commons/components/HcSkeletonItem'
import { QuestionListComp } from '../../commons/components/QuestionListComp'
import { httpClient } from '../../commons/utils/httpClient'
import { QuestionType, SortType } from '../../models'
import { emitter } from '@kit.BasicServicesKit'
import { logger } from '../../commons/utils/logger'
import { LOGIN_EVENT_NAME } from '../../commons/contants'

@Component
export struct HomeCategory {
  @StorageProp('isDark') isDark: boolean = false

  @State activeIndex: number = 0
  @State sort: number = SortType.Default
  @State questionTypeList: QuestionType[] = []
  @State loading: boolean = false
  // 支撑筛选
  @State show: boolean = false
  @State filterDataSort: SortType = SortType.Default
  @State filterDataIndex: number = 0

  aboutToAppear(): void {
    this.getQuestionTypeList()
    // emitter.on('test', (e) => {
    //   // emitter.emit('test') 触发事件，执行该回调函数
    //   logger.debug('emitter', JSON.stringify(e.data))
    // })
    emitter.on(LOGIN_EVENT_NAME, () => {
      this.getQuestionTypeList()
    })
  }

  async getQuestionTypeList() {
    this.loading = true
    const res = await httpClient.request<QuestionType[]>({ url: 'question/type' })
    this.questionTypeList = res
    this.loading = false
  }

  @Builder
  TabBarBuilder(item: QuestionType, i: number) {
    Row({ space: 4 }) {
      Stack({ alignContent: Alignment.Bottom }) {
        Text(item.name)
          .fontSize(15)
          .height(44)
          .fontColor(this.activeIndex === i ? $r('app.color.black') : $r('app.color.common_gray_02'))
        Text()
          .width(this.activeIndex === i ? 20 : 0)
          .height(2)
          .backgroundColor($r('app.color.black'))
          .animation({ duration: this.activeIndex === i ? 300 : 0 })
      }

      if (item.displayNewestFlag === 1) {
        Image($r('app.media.ic_home_new'))
          .width(32)
          .height(14)
          .objectFit(ImageFit.Contain)
          .margin({ left: 4 })
      }
    }
    .padding({ left: 16, right: this.questionTypeList.length - 1 === i ? 56 : 0 })
  }

  @Builder
  FilterSheetBuilder() {
    Column() {
      Row() {
        Text('重置')
          .fontSize(16)
          .fontWeight(500)
          .fontColor($r('app.color.common_gray_03'))
          .onClick(() => {
            this.filterDataSort = SortType.Default
            this.filterDataIndex = 0
          })
        Text('筛选题目')
          .layoutWeight(1)
          .fontSize(18)
          .fontWeight(500)
          .fontColor($r('app.color.black'))
          .textAlign(TextAlign.Center)
        Text('完成')
          .fontWeight(500)
          .fontSize(16)
          .fontColor($r('app.color.common_main_color'))
          .onClick(() => {
            this.activeIndex = this.filterDataIndex
            this.sort = this.filterDataSort
            this.show = false
          })
      }
      .margin({ bottom: 4, top: 4 })

      Text('题目排序')
        .textTitle()
      Flex({ wrap: FlexWrap.Wrap }) {
        FilterButton({ text: '默认', selected: this.filterDataSort === SortType.Default })
          .onClick(() => {
            this.filterDataSort = SortType.Default
          })
        FilterButton({
          text: '浏览量',
          isSort: true,
          sort: this.filterDataSort,
          selected: this.filterDataSort === SortType.ViewLow || this.filterDataSort === SortType.ViewHigh
        })
          .onClick(() => {
            // 已经选中
            if (this.filterDataSort === SortType.ViewLow || this.filterDataSort === SortType.ViewHigh) {
              this.filterDataSort = this.filterDataSort === SortType.ViewLow ? SortType.ViewHigh: SortType.ViewLow
            } else {
              this.filterDataSort = SortType.ViewHigh
            }
          })
        FilterButton({
          text: '难度',
          isSort: true,
          sort: this.filterDataSort,
          selected: this.filterDataSort === SortType.DifficultyLow || this.filterDataSort === SortType.DifficultyHigh
        })
          .onClick(() => {
            // 已经选中
            if (this.filterDataSort === SortType.DifficultyLow || this.filterDataSort === SortType.DifficultyHigh) {
              this.filterDataSort = this.filterDataSort === SortType.DifficultyLow ? SortType.DifficultyHigh: SortType.DifficultyLow
            } else {
              this.filterDataSort = SortType.DifficultyHigh
            }
          })
        FilterButton({ text: '推荐', selected: this.filterDataSort === SortType.Commend })
          .onClick(() => {
            this.filterDataSort = SortType.Commend
          })
      }

      Text('选择分类')
        .textTitle()
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.questionTypeList, (item: QuestionType, i) => {
          FilterButton({ text: item.name, isNew: item.displayNewestFlag === 1, selected: this.filterDataIndex === i })
            .onClick(() => {
              this.filterDataIndex = i
            })
        })
      }
    }
    .padding(16)
    .backgroundColor($r('app.color.white'))
    .height('100%')
  }

  @Builder
  SkeletonBuilder () {
    HcSkeleton(){
      Column(){
        Row({ space: 16 }){
          HcSkeletonItem({ widthValue: 50 })
          HcSkeletonItem({ widthValue: 80 })
          HcSkeletonItem({ widthValue: 60 })
          HcSkeletonItem({ widthValue: 50 })
        }
        .height(44)
        ForEach([1,2,3,4,5,6], () => {
          Column({ space: 10 }){
            HcSkeletonItem({ widthValue: '90%' })
            HcSkeletonItem({ widthValue: '50%' })
          }
          .alignItems(HorizontalAlign.Start)
          .height(80)
        })
      }
      .alignItems(HorizontalAlign.Start)
      .padding({ left: 16, right: 16 })
      .width('100%')
    }
  }

  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      if (this.loading) {
        this.SkeletonBuilder()
      } else {
        Tabs({ index: this.activeIndex }) {
          ForEach(this.questionTypeList, (item: QuestionType, i) => {
            TabContent() {
              QuestionListComp({ typeId: item.id, sort: this.sort, activeIndex: this.activeIndex, index: i })
            }
            .tabBar(this.TabBarBuilder(item, i))
          })
        }
        .divider({ strokeWidth: 0.5, color: $r('app.color.common_gray_border') })
        .barMode(BarMode.Scrollable)
        .barHeight(44)
        .onTabBarClick(i => {
          this.activeIndex = i
        })
      }

      // 筛选按钮
      Row() {
        Image($r('app.media.ic_home_filter'))
          .width(24)
          .aspectRatio(1)
      }
      .width(56)
      .height(44)
      .justifyContent(FlexAlign.Center)
      .linearGradient({
        angle: 90,
        colors: [[ this.isDark? '#00000000' : '#00FFFFFF', 0], [this.isDark? '#131313' : '#FFFFFF', 0.285]]
      })
      .onClick(() => {
        this.filterDataIndex = this.activeIndex
        this.show = true
      })
    }
    .width('100%')
    .layoutWeight(1)
    .backgroundColor($r('app.color.white'))
    .bindSheet($$this.show, this.FilterSheetBuilder(), {
      showClose: false,
      height: 400
    })
  }
}

@Extend(Text)
function textTitle() {
  .fontSize(14)
  .fontWeight(500)
  .fontColor($r('app.color.black'))
  .width('100%')
  .margin({ top: 20, bottom: 12 })
}


@Component
struct FilterButton {
  @Prop text: string = ''
  @Prop isSort: boolean = false
  @Prop isNew: boolean = false
  @Prop selected: boolean = false
  @Prop sort: SortType = SortType.Default

  build() {
    Row() {
      Text(this.text)
        .fontSize(12)
        .fontColor(this.selected ? $r('app.color.common_main_color') : $r('app.color.black'))
      if (this.isSort) {
        // 偶数升序 low  奇数降序 high
        Column() {
          Image($r('sys.media.ohos_ic_public_arrow_up'))
            .size({ width: 12, height: 6 })
            .fillColor(this.selected && (this.sort % 2) === 0 ? $r('app.color.common_main_color') : $r('app.color.black'))
          Image($r('sys.media.ohos_ic_public_arrow_down'))
            .size({ width: 12, height: 6 })
            .fillColor(this.selected && (this.sort % 2) === 1 ? $r('app.color.common_main_color') : $r('app.color.black'))
        }
        .margin({ left: 2 })
      }
      if (this.isNew) {
        Image($r('app.media.ic_home_new'))
          .width(32)
          .height(14)
          .objectFit(ImageFit.Contain)
          .position({ right: -26, top: -7 })
      }
    }
    .height(32)
    .padding({ left: 10, right: 10 })
    .borderRadius(4)
    .backgroundColor($r('app.color.common_gray_bg'))
    .margin({ bottom: 12, right: this.isNew ? 26 : 10 })
  }
}