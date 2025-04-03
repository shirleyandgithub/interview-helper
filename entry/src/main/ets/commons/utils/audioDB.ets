import { relationalStore, ValuesBucket } from '@kit.ArkData'

export interface InterviewAudioItem extends ValuesBucket {
  id: number | null
  user_id: string
  name: string
  path: string
  duration: number
  size: number
  create_time: number
}

class AudioDB {
  store?: relationalStore.RdbStore
  tableName: string = 'interview_audio'

  // 初始化数据库实例
  async initDB() {
    const ctx = AppStorage.get<Context>('context')
    if (ctx) {
      // 获取数据库实例
      const store = await relationalStore.getRdbStore(ctx, {
        name: 'interview_record.db',
        securityLevel: relationalStore.SecurityLevel.S2
      })

      // 第一次创建数据库
      if (store.version === 0) {
        // 建表
        await store.executeSql(`
          CREATE TABLE IF NOT EXISTS ${this.tableName} (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT NOT NULL,
            name TEXT NOT NULL,
            path TEXT NOT NULL,
            duration INTEGER NOT NULL,
            size INTEGER NOT NULL,
            create_time INTEGER NOT NULL
          )
        `)
        store.version = 2
      }

      this.store = store
    }
  }

  // 添加
  async insert(item: InterviewAudioItem) {
    const rowId = await this.store?.insert(this.tableName, item)
    if (rowId === undefined || rowId === -1) {
      return Promise.reject('insert fail')
    }
    return Promise.resolve()
  }

  // 删除
  async delete(id: number) {
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    predicates.equalTo('id', id)
    const rowCount = this.store?.deleteSync(predicates)
    if (rowCount === undefined || rowCount === 0) {
      return Promise.reject('delete fail')
    }
    return Promise.resolve()
  }

  // 修改
  async update(item: InterviewAudioItem) {
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    predicates.equalTo('id', item.id)
    const rowCount = this.store?.updateSync(item, predicates)
    if (rowCount === undefined || rowCount === 0) {
      return Promise.reject('update fail')
    }
    return Promise.resolve()
  }

  // 查询
  async query(user_id: string) {
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    predicates.equalTo('user_id', user_id)

    const resultSet = await this.store?.query(predicates)
    if (resultSet === undefined) {
      return Promise.reject('query fail')
    }

    const list: InterviewAudioItem[] = []
    while (resultSet.goToNextRow()) {
      list.push({
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        user_id: resultSet.getString(resultSet.getColumnIndex('user_id')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        path: resultSet.getString(resultSet.getColumnIndex('path')),
        duration: resultSet.getLong(resultSet.getColumnIndex('duration')),
        size: resultSet.getLong(resultSet.getColumnIndex('size')),
        create_time: resultSet.getLong(resultSet.getColumnIndex('create_time')),
      })
    }
    resultSet.close()
    return Promise.resolve(list)
  }

}

export const audioDB = new AudioDB()