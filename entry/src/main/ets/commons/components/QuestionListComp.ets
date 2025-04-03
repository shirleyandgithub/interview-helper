import { PageData, QuestionDetailParams, QuestionItem, QuestionListParams, SortType } from "../../models"
import { httpClient } from "../utils/httpClient"
import { QuestionItemComp } from "./QuestionItemComp"
import { promptAction } from "@kit.ArkUI"
import { auth } from "../utils/auth"

@Component
export struct QuestionListComp {
  @Prop typeId: number
  @Prop @Watch('onChange') sort: SortType = SortType.Default
  @Prop activeIndex: number
  @Prop index: number
  @Prop keyword: string = ''
  @State page: number = 1
  @State isRefreshing: boolean = false
  @State isLoading: boolean = false
  @State isFinished: boolean = false
  @State list: QuestionItem[] = []

  onChange () {
    if (this.activeIndex === this.index) {
      // 排序改变触发更新（当前激活的选项卡的试题列表才触发）
      this.isRefreshing = true
    }
  }

  // 获取试题列表
  getQuestionList(): Promise<PageData<QuestionItem>> {
    return httpClient.request<PageData<QuestionItem>>({
      url: 'question/list',
      params: {
        type: this.typeId,
        questionBankType: 10,
        sort: this.sort,
        page: this.page,
        pageSize: 10,
        keyword: this.keyword
      } as QuestionListParams
    })
  }

  async onRefresh() {
    // 需求：重新更新第一页数据
    this.page = 1
    const res = await this.getQuestionList()
    this.list = res.rows
    this.isRefreshing = false
    // 有没有更多数据
    if (this.page >= res.pageTotal) {
      this.isFinished = true
    } else {
      this.isFinished = false
      this.page ++
    }
    promptAction.showToast({ message: '已更新' })
  }

  async onLoad() {
    this.isLoading = true
    const res = await this.getQuestionList()
    this.list.push(...res.rows)
    this.isLoading = false
    // 有没有更多数据
    if (this.page >= res.pageTotal) {
      this.isFinished = true
    } else {
      this.page++
    }
  }

  @Builder
  LoadMoreBuilder() {
    ListItem() {
      // 是否列表所有的数据加载完毕（没有更多数据了）
      if (this.isFinished) {
        Row() {
          Text('没有更多了~')
            .fontSize(14)
            .fontColor($r('app.color.common_gray_03'))
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
      } else if (this.isLoading) {
        Row({ space: 4 }) {
          LoadingProgress()
            .width(20)
          Text('正在加载...')
            .fontSize(14)
            .fontColor($r('app.color.common_gray_03'))
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
      }
    }
    .height(80)
  }

  build() {
    Refresh({ refreshing: $$this.isRefreshing }) {
      List() {
        ForEach(this.list, (item: QuestionItem) => {
          ListItem() {
            QuestionItemComp({
              item
            })
              .onClick(() => {
                auth.checkAuth({
                  url: 'pages/QuestionPage',
                  params: { item: item, list: this.list } as QuestionDetailParams
                })
              })
          }
        })
        // 加载更多容器
        this.LoadMoreBuilder()
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None)
      .divider({
        strokeWidth: 0.5,
        color: $r('app.color.common_gray_border'),
        startMargin: 16,
        endMargin: 16,
      })
      .onReachEnd(() => {
        // 思考？没有更多数据，正在加载中，正在刷新中，都不能去加载
        if (this.isFinished || this.isLoading || this.isRefreshing) {
          return
        }
        this.onLoad()
      })
    }
    .onRefreshing(() => {
      this.onRefresh()
    })
  }
}