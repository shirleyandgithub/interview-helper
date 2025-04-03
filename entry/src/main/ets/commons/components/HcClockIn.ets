@Component
export struct HcClockIn {
  // 展示两种情况：未打卡 已打卡   使用连续打卡天数 > 0
  @Prop clockInCount: number = 0

  build() {
    Row(){
      // 连续打卡
      // 10天
      if (this.clockInCount > 0) {
        Column(){
          Text('连续打卡')
            .fontSize(8)
            .fontColor($r('app.color.black'))
          Text(){
            Span(this.clockInCount.toString())
              .fontSize(10)
              .fontWeight(600)
            Span('天')
              .fontSize(8)
          }
          .fontColor($r('app.color.black'))
        }
        .margin({ left: 30 })
      }
      // 打卡
      else {
        Text('打卡')
          .fontSize(18)
          .fontWeight(600)
          .fontColor($r('app.color.black'))
          .margin({ left: 30 , top: -4 })
      }
    }
    .width(74)
    .height(28)
    .backgroundImage($r('app.media.ic_common_clocked'))
    .backgroundImageSize(ImageSize.Contain)
  }
}