import { preferences } from '@kit.ArkData'

class History {
  // 1. 初始化 store
  store: preferences.Preferences | null = null
  getStore () {
    if (!this.store) {
      const ctx = AppStorage.get<Context>('context')
      const store = preferences.getPreferencesSync(ctx, { name: 'history-store' })
      this.store = store
    }
    return this.store
  }
  // 2. 存储历史记录  putSync('arkTS', 'arkTS')  putSync('vue', 'vue')
  async setItem (keyword: string) {
    this.getStore().putSync(keyword, keyword)
    await this.getStore().flush()
  }
  // 3. 删除历史记录
  async delItem (keyword: string) {
    this.getStore().deleteSync(keyword)
    await this.getStore().flush()
  }

  // 4. 清空历史记录
  async clear () {
    this.getStore().clearSync()
    await this.getStore().flush()
  }

  // 5. 获取所有记录  getAllSync()  ===> 所有数据取出来会是一个对象{'arkTS':'arkTS','vue':'vue'}  ===>  数组
  getAll() {
    const obj = this.getStore().getAllSync()
    return Object.keys(obj) // ===> [ 'arkTS', 'vue' ]
  }
}

export const history = new History()