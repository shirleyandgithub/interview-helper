// import { preferences } from '@kit.ArkData'
import { relationalStore, ValuesBucket } from '@kit.ArkData'
import { BusinessError } from '@kit.BasicServicesKit'
import { logger } from '../commons/utils/logger'
import { promptAction } from '@kit.ArkUI'

// import { promptAction } from '@kit.ArkUI'
//
// @Entry
// @Component
// struct TestPage {
//
//   store: preferences.Preferences | null = null
//
//   aboutToAppear(): void {
//     // 创建仓库
//     this.store = preferences.getPreferencesSync(getContext(this), { name: 'test-store' })
//   }
//
//   build() {
//     Column({ space: 16 }) {
//       Text('preferences 首选项')
//       Button('增')
//         .onClick(() => {
//           this.store?.putSync('name', 'jack')
//           this.store?.flush()
//         })
//       Button('读')
//         .onClick(() => {
//           const val = this.store?.getSync('name', '')
//           promptAction.showToast({ message: val?.toString() })
//         })
//       Button('改')
//         .onClick(() => {
//           this.store?.putSync('name', 'tom')
//           this.store?.flush()
//         })
//       Button('删')
//         .onClick(() => {
//           this.store?.deleteSync('name')
//           this.store?.flush()
//         })
//       Button('删库')
//         .onClick(() => {
//           preferences.deletePreferences(getContext(this), { name: 'test-store' })
//         })
//     }
//     .height('100%')
//     .width('100%')
//   }
// }

interface ArticleItem extends ValuesBucket {
  id: number
  title: string
  content: string
  create_time: string
}

@Entry
@Component
struct TestPage {
  store?: relationalStore.RdbStore
  tableName: string = 'article'

  async createStore() {
    const ctx = getContext(this)
    // 建库
    const store = await relationalStore.getRdbStore(ctx, {
      name: 'article.db',
      securityLevel: relationalStore.SecurityLevel.S1
    })
    // 建表
    await store.executeSql(`
      CREATE TABLE IF NOT EXISTS ${this.tableName} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        create_time INTEGER NOT NULL
      )
    `)
    this.store = store
  }

  list: ArticleItem[] = []

  build() {
    Column({ space: 16 }) {
      Button('初始化数据库对象')
        .onClick(() => {
          this.createStore()
        })

      Button('添加文章')
        .onClick(() => {
          this.store?.insert(this.tableName, {
            title: '第一篇文章',
            content: '文章的内容10010010',
            create_time: Date.now()
          }).catch((e: BusinessError) => {
            logger.error('store', JSON.stringify(e))
          })
        })

      Button('查询文章数量')
        .onClick(async () => {
          const predicates = new relationalStore.RdbPredicates(this.tableName)
          const result = await this.store?.query(predicates)
          promptAction.showToast({ message: result?.rowCount.toString() })
        })

      Button('查询文章列表')
        .onClick(async () => {
          const predicates = new relationalStore.RdbPredicates(this.tableName)
          const result = await this.store?.query(predicates)
          const list: ArticleItem[] = []
          if (result) {
            while (result.goToNextRow()) {
              list.push({
                id: result.getLong(result.getColumnIndex('id')),
                title: result.getString(result.getColumnIndex('title')),
                content: result.getString(result.getColumnIndex('content')),
                create_time: result.getString(result.getColumnIndex('create_time'))
              })
            }
            result.close()
            this.list = list
            promptAction.showDialog({ message: JSON.stringify(list) })
          }
        })

      Button('修改第一篇文章')
        .onClick(async () => {
          const item = this.list[0]  // 先查出list
          if (item) {
            const predicates = new relationalStore.RdbPredicates(this.tableName)
            predicates.equalTo('id', item.id)

            item.title = '修改的TITLE'
            this.store?.updateSync(item, predicates);
            promptAction.showToast({ message: '修改成功' })
          }
        })

      Button('删除最后一篇文章')
        .onClick(async () => {
          const item = this.list[this.list.length-1]  // 先查出list
          if (item) {
            const predicates = new relationalStore.RdbPredicates(this.tableName)
            predicates.equalTo('id', item.id)

            this.store?.deleteSync(predicates)
            promptAction.showToast({ message: '删除成功' })
          }
        })

      Button('删库')
        .onClick(async () => {
          const ctx = getContext(this)
          relationalStore.deleteRdbStore(ctx, {
            name: 'article.db',
            securityLevel: relationalStore.SecurityLevel.S1
          })
        })
    }
    .padding(50)
    .width('100%')
    .height('100%')
  }
}