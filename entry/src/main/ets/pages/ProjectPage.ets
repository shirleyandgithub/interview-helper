import { logger } from "../commons/utils/logger"

@Component
export struct ProjectPage {
  // 分析：
  // 1. 使用 grid 栅格布局
  // 2. 当前月多少天就有点代表
  // 3. 每个月第一天星期几需要偏移
  // 4. 激活当前日期

  @State days: Date[] = []
  @State offsetDay: number = 0
  @State currentDate: Date = new Date()

  aboutToAppear(): void {
    // 1. 组织当前月的日期数组
    // 思路：取的下一个月的号是0的日期（当前月最后一天的日期）
    const now = new Date()
    const year = now.getFullYear()
    const month = now.getMonth()
    const date = now.getDate()
    const currentMonthLastDate = new Date(year, month + 1, 0).getDate()
    for (let index = 1; index <= currentMonthLastDate; index++) {
      this.days.push(new Date(year, month, index))
    }
    // 2. 算出当前月第一天是星期几
    const firstDate = this.days[0]
    this.offsetDay = firstDate.getDay()
    // 3. 算出当前时间的 0点的毫秒数的日期
    this.currentDate = new Date(year, month, date)
  }

  build() {
    Column() {
      GridRow({ columns: 7, gutter: 16 }) {
        ForEach(this.days, (date: Date, i) => {
          GridCol({ offset: i === 0 ? this.offsetDay : 0 }) {
            Text()
              .width(8)
              .height(8)
              .border({
                width: 2,
                color: this.currentDate.getTime() === date.getTime() ? $r('app.color.common_green') :
                $r('app.color.common_gray_01'),
                radius: 4
              })
          }
        })
      }
    }
  }
}