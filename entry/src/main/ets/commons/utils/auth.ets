// 1. 维护用户的KEY
// 2. 提供操作用户信息（登录凭证）的方法
import { User } from "../../models"
import { router } from "@kit.ArkUI"

export const UserStoreKey = 'hm-user'

class Auth {
  // 初始化
  initUser() {
    PersistentStorage.persistProp<User>(UserStoreKey, {} as User)
  }

  // 获取用户
  getUser() {
    return AppStorage.get<User>(UserStoreKey) || {} as User
  }

  // 设置用户
  setUser(user: User) {
    AppStorage.setOrCreate(UserStoreKey, user)
  }

  // 鉴权
  checkAuth(options: Function | router.RouterOptions) {
    const user = this.getUser()
    if (typeof options === 'function') {
      // 1. 执行某些业务逻辑，判断是否登录，如果登录执行业务逻辑，如果没有跳转登录页
      if (user.token) {
        options()
      } else {
        router.pushUrl({ url: 'pages/LoginPage' })
      }
    } else {
      // 2. 跳转页面的时候，判断是否登录，如果登录跳转目标页面，如果没有跳转到登录页且登录成功跳转目标页(考虑参数)
      if (user.token) {
        router.pushUrl(options)
      } else {
        // checkAuth({ url: 'pages/QuestionPage', params: { id: 100 } })
        // a 跳转登录，跳转url+params给登录
        // b 登录成功，按照url+params来跳转
        const params = options.params as Record<string, string> || {}
        params.return_url = options.url
        router.pushUrl({ url: 'pages/LoginPage', params: params })
      }
    }
  }
}

export const auth = new Auth()