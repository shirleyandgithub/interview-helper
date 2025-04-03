@Component
export struct HcSearchBox {
  // 需求：宽 高 背景 占位文字 占位文字颜色 父剩余空间占比
  @Prop widthValue: number = 100
  @Prop heightValue: number = 32
  @Prop bgColor: ResourceColor = $r('app.color.common_gray_border')
  @Prop ph: string = '搜索题目'
  @Prop phColor: ResourceColor = $r('app.color.common_gray_02')
  @Prop layoutWeightValue: number = 0

  onClickFn: () => void = () => {}

  build() {
    Row({ space: 2 }){
      Image($r('app.media.ic_common_search'))
        .width(14)
        .aspectRatio(1)
        .fillColor(this.phColor)
      Text(this.ph)
        .fontSize(14)
        .fontColor(this.phColor)
    }
    .width(this.widthValue)
    .height(this.heightValue)
    .backgroundColor(this.bgColor)
    .borderRadius(this.heightValue / 2)
    .layoutWeight(this.layoutWeightValue)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.onClickFn()
    })
  }
}