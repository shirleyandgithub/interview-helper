@Component
export struct HcSkeleton {
  @State opacityValue: number = 1

  @Builder
  DefaultBuilder() {
  }

  // HcSkeleton({ default: 'Builder函数' }) 如果只有一个BuilderParam使用尾随闭包 HcSkeleton(){ // 写结构即可 }
  @BuilderParam default: () => void = this.DefaultBuilder

  build() {
    Row() {
      // 这里面放的结构取决于我们使用组件时
      this.default()
    }
    // 透明度 1 -> 0.5 -> 1 ... 无限次数动画
    .opacity(this.opacityValue)
    .animation({
      duration: 600,
      iterations: -1,
      playMode: PlayMode.Alternate, // 来回执行
      curve: Curve.Linear
    })
    .onAppear(() => {
      // 组件渲染好
      this.opacityValue = 0.5
    })
  }
}