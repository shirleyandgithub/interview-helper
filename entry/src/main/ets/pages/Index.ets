import { auth } from '../commons/utils/auth'
import { theme } from '../commons/utils/theme'
import { HomePage } from './HomePage'
import { InterviewPage } from './InterviewPage'
import { MinePage } from './MinePage'
import { ProjectPage } from './ProjectPage'

interface TabItem {
  name: string
  icon: Resource
  activeIcon: Resource
}

auth.initUser()
theme.initTheme()

@Entry
@Component
struct Index {
  @StorageProp('bottomHeight') bottomHeight: number = 0
  @State activeIndex: number = 0

  // 基于tab数据来实现
  tabList: TabItem[]  = [
    { name: '首页', icon: $r('app.media.tabbar_home'), activeIcon: $r('app.media.tabbar_home_fill') },
    { name: '项目', icon: $r('app.media.tabbar_project'), activeIcon: $r('app.media.tabbar_project_fill') },
    { name: '面经', icon: $r('app.media.tabbar_interview'), activeIcon: $r('app.media.tabbar_interview_fill') },
    { name: '我的', icon: $r('app.media.tabbar_mine'), activeIcon: $r('app.media.tabbar_mine_fill') }
  ]

  @Builder TabItemBuilder (item: TabItem, i: number) {
    Column({ space: 4 }){
      Image(this.activeIndex === i ? item.activeIcon : item.icon)
        .width(24)
        .aspectRatio(1)
      Text(item.name)
        .fontSize(12)
        .fontColor(this.activeIndex === i ? $r('app.color.black') : $r('app.color.common_gray_01'))
    }
  }

  build() {
    Column(){
      Tabs({ barPosition: BarPosition.End , index: this.activeIndex}){
        ForEach(this.tabList, (item: TabItem, i) => {
          TabContent(){
            if (i === 0) {
              HomePage()
            } else if ( i === 1) {
              ProjectPage()
            } else if ( i === 2) {
              InterviewPage()
            } else if (i === 3) {
              MinePage()
            }
          }.tabBar(this.TabItemBuilder(item, i))
        })
      }
      .divider({ strokeWidth: 0.5, color: $r('app.color.common_gray_border') })
      .scrollable(false)
      .onTabBarClick(i => {
        this.activeIndex = i
      })
      .margin({ bottom: this.bottomHeight })
    }
    .width('100%')
    .height('100%')
  }
}