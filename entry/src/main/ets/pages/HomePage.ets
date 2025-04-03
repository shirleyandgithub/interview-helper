import { HcClockIn } from "../commons/components/HcClockIn"
import { HcSearchBox } from "../commons/components/HcSearchBox"
import { auth, UserStoreKey } from "../commons/utils/auth"
import { logger } from "../commons/utils/logger"
import { HomeCategory } from "../views/Home/HomeCategory"
import { scanBarcode } from "@kit.ScanKit"
import { httpClient } from "../commons/utils/httpClient"
import { QuestionDetail, QuestionDetailParams, User } from "../models"
import { promptAction, router } from "@kit.ArkUI"
import { tracking } from "../commons/utils/Tracking"
import { requestClockIn } from "../commons/utils"

@Component
export struct HomePage {
  @StorageProp('topHeight') topHeight: number = 0
  @StorageProp(UserStoreKey) user: User = {} as User


  aboutToAppear(): void {
    tracking.report(true)
  }

  async scanQuestionCode() {
    // 判断某些个能力当前设备是否支持
    if (canIUse('SystemCapability.Multimedia.Scan.ScanBarcode')) {
      // 1. 调起扫码界面
      const result = await scanBarcode.startScanForResult(getContext(this))
      // 2. 根据结果查询试题
      if (result.originalValue) {
        try {
          const item = await httpClient.request<QuestionDetail>({ url: `question/${result.originalValue}` })
          // 3. 跳转试题详情
          router.pushUrl({
            url: 'pages/QuestionPage',
            params: {
              item,
              list: [item]
            } as QuestionDetailParams
          })
        } catch (e) {
          promptAction.showToast({ message: '没有找到试题' })
        }
      }
    }
  }

  @Builder
  SwiperItemBuilder(src: Resource) {
    Row() {
      Image(src)
        .width('100%')
        .aspectRatio(2.65)
        .objectFit(ImageFit.Fill)
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
  }

  build() {
    Column() {
      Row({ space: 16 }) {
        Image($r('app.media.ic_home_scan'))
          .width(24)
          .aspectRatio(1)
          .onClick(() => {
            auth.checkAuth(() => {
              this.scanQuestionCode()
            })
          })
        // 搜索盒子
        HcSearchBox({ layoutWeightValue: 1 , onClickFn: () => {
          router.pushUrl({ url: 'pages/SearchPage' })
        }})
        // 打卡
        HcClockIn({ clockInCount: this.user.clockinNumbers || 0  })
          .onClick(() => {
            requestClockIn()
          })
      }
      .padding({ left: 16, right: 16 })
      .width('100%')
      .height(64)

      Swiper() {
        ForEach([$r('app.media.banner_qa'), $r('app.media.banner_pj'), $r('app.media.banner_ai')], (src: Resource) => {
          this.SwiperItemBuilder(src)
        })
      }
      .onClick(() => {
        router.pushUrl({ url: 'pages/TestPage' })
      })
      .margin({ bottom: 16 })
      .autoPlay(true)
      .indicator(DotIndicator.dot()
        .bottom(4)
        .itemWidth(10)
        .itemHeight(4)
        .selectedItemHeight(4)
        .selectedItemWidth(10)
        .selectedColor($r('app.color.white')))

      // 分类组件
      HomeCategory()
    }
    .padding({ top: this.topHeight })
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.common_gray_bg'))
  }
}