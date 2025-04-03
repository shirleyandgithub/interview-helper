import { HcNavBar } from '../commons/components/HcNavBar'
import { HmCalendar, HmCalendarSelectedDay } from '@ohmos/calendar'
import { httpClient } from '../commons/utils/httpClient'
import { ClockInfo, ClockInfoParams } from '../models'

interface DayBuilderParams {
  day: number
  text: string
}

@Entry
@Component
struct ClockInPage {
  @State info: ClockInfo = {
    flag: false,
    clockinNumbers: 0,
    totalClockinNumber: 0,
    clockins: []
  }
  @State selectedDays: HmCalendarSelectedDay[]  = []

  aboutToAppear(): void {
    const now = new Date()
    this.getClockInfo(now.getFullYear().toString(), (now.getMonth() + 1).toString())
  }

  async getClockInfo (year: string, month: string) {
    const res = await httpClient.request<ClockInfo>({ url: 'clockinInfo', params: {
      year,
      month
    } as ClockInfoParams })
    this.info = res
    // 打卡选中
    this.selectedDays = res.clockins.map(item => ({ date: item.createdAt } as HmCalendarSelectedDay))
  }

  @Builder
  dayBuilder(params: DayBuilderParams) {
    Column() {
      Row() {
        Text(params.day.toString())
          .fontSize(40)
          .fontWeight(FontWeight.Bold)
        Text('天')
          .fontSize(10)
          .fontColor($r('app.color.common_gray_01'))
          .margin({ bottom: 8, left: 10 })
      }
      .alignItems(VerticalAlign.Bottom)

      Text(params.text)
        .fontSize(10)
        .fontColor($r('app.color.common_gray_01'))
    }.margin({ right: 36 })
  }

  build() {
    Column({ space: 16 }) {
      HcNavBar({ title: '每日打卡', showRightIcon: false })
      Row() {
        this.dayBuilder({ day: this.info.totalClockinNumber, text: '累计打卡' })
        this.dayBuilder({ day: this.info.clockinNumbers, text: '连续打卡' })
      }
      .padding({ top: 10, bottom: 25, left: 16, right: 16 })
      .width('100%')
      .justifyContent(FlexAlign.Start)

      Row() {
        HmCalendar({
          selectedDays: this.selectedDays,
          onChangeMonth: (date) => {
            // date ===> '2024-10' or '2023-08'
            const arr = date.split('-')
            this.getClockInfo(arr[0], arr[1])
          }
        })
          .borderRadius(8)
          .border({ width: 0.5, color: '#ededed' })
          .shadow({ color: '#ededed', radius: 16 })
          .backgroundColor($r('app.color.white'))
      }
      .padding({ left: 16, right: 16 })
    }
    .width('100%')
    .height('100%')
    .backgroundImage($r('app.media.clocked_bg'))
    .backgroundImageSize({ width: '100%' })
  }
}