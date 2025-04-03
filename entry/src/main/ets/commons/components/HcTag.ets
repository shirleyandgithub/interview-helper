@Component
export struct HcTag {
  // 需求：5 困难  3-4 一般  1-2 简单  --- 题目难度
  @Prop difficulty: number = 1
  // 需求：自定义 文字和颜色
  @Prop text: string
  @Prop color: ResourceColor

  build() {
    Text(this.text || infoMap[this.difficulty].text)
      .fontColor(this.color || infoMap[this.difficulty].color)
      .fontSize(10)
      .padding({ left: 6, right: 6 })
      .height(18)
      .constraintSize({ minWidth: 34 })
      .borderRadius(2)
      .backgroundColor($r('app.color.common_gray_bg'))
      .textAlign(TextAlign.Center)
  }
}

interface HcTagInfo {
  text: string;
  color: ResourceColor;
}

const infoMap: Record<number, HcTagInfo> = {
  1: { text: '简单', color: $r('app.color.common_green') },
  2: { text: "简单", color: $r("app.color.common_green") },
  3: { text: "一般", color: $r("app.color.common_blue") },
  4: { text: "一般", color: $r("app.color.common_blue") },
  5: { text: "困难", color: $r("app.color.common_main_color") },
}
