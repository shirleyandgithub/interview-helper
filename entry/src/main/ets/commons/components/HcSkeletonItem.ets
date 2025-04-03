@Component
export struct HcSkeletonItem {
  @Prop widthValue: Length = '100%'

  build() {
    Text()
      .width(this.widthValue)
      .height(16)
      .borderRadius(2)
      .backgroundColor($r('app.color.common_gray_bg'))
  }
}