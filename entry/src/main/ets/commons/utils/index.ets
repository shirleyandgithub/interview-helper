// 提供通用工具函数
import { huks } from "@kit.UniversalKeystoreKit"
import { auth } from "./auth"
import { promptAction, router } from "@kit.ArkUI"
import { httpClient } from "./httpClient"

export const formatTime = (second: number) => {
  // 天 > 1天
  // 时 > 1小时
  // 分 > 分钟
  const day = 60 * 60 * 24
  const hour = 60 * 60
  const min = 60

  if (second > day) {
    return (second / day).toFixed(1) + '天'
  } else if (second > hour) {
    return (second / hour).toFixed(1) + '小时'
  } else {
    return (second / min).toFixed(0) + '分钟'
  }
}

interface ClockRes {
  clockinNumbers: number
}

export const requestClockIn = async () => {
  const user = auth.getUser()
  if (user.token) {
    if (user.clockinNumbers === 0) {
      // 完成打卡
      const res = await httpClient.request<ClockRes>({ url: 'clockin', method: 'post' })
      user.clockinNumbers = res.clockinNumbers
      auth.setUser(user)
      promptAction.showToast({ message: '打卡完成' })
    }
    router.pushUrl({ url: 'pages/ClockInPage' })
  } else {
    router.pushUrl({ url: 'pages/LoginPage' })
  }
}


export const calcPercentage = (done: number, total: number) => {
  return Math.round(done / total * 100) + '%'
}