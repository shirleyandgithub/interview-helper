import { TimeItem } from '../../models'
import { logger } from './logger'
import { httpClient } from './httpClient'
import { preferences } from '@kit.ArkData'
import { JSON } from '@kit.ArkTS'

class Tracking {
  dataKey: string = 'time-list'
  store: preferences.Preferences | null = null

  // 获取首选项仓库实例
  getStore() {
    if (!this.store) {
      const ctx = AppStorage.get<Context>('context')
      const store = preferences.getPreferencesSync(ctx, { name: 'tracing-store' })
      this.store = store
    }
    return this.store
  }

  // 记录
  async record(questionId: string, startTime: number, endTime: number) {
    const json = this.getStore().getSync(this.dataKey, '[]')
    const list = JSON.parse(json as string) as TimeItem[]
    list.push({ questionId, startTime, endTime })
    this.getStore().putSync(this.dataKey, JSON.stringify(list))
    await this.getStore().flush()
  }

  // 上报
  async report(force: boolean = false) {
    const json = this.getStore().getSync(this.dataKey, '[]')
    const list = JSON.parse(json as string) as TimeItem[]
    if (list.length >= 5 || (force && list.length)) {
      await httpClient.request<null>({ url: 'time/tracking', method: 'post', data: { timeList: list } })
      this.getStore().deleteSync(this.dataKey)
      await this.getStore().flush()
    }
  }
}

export const tracking = new Tracking()