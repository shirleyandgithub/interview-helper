@Component
export struct AudioBoComp {
  @Prop @Watch('onChange') maxAmplitude: number = 0

  // 显示柱子高度是100的多少
  @State per: number = 0

  onChange () {
    animateTo({ duration: 100 }, () => {
      if (this.maxAmplitude < 500) {
        this.per = 0
      } else if (this.maxAmplitude > 32000) {
        this.per = 1
      } else {
        this.per = this.maxAmplitude / 32000
      }
    })
  }

  build() {
    Row({ space: 5 }){
      ForEach(new Array(30).fill(0), () => {
        Column()
          .layoutWeight(1)
          .backgroundColor($r('app.color.common_blue'))
          .height(this.per * 100 * Math.random())
      })
    }
    .width('100%')
    .height(100)
  }
}