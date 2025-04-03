import axios, { AxiosError, AxiosRequestConfig, AxiosResponse, InternalAxiosRequestConfig } from '@ohos/axios'
import { User } from '../../models'
import { auth } from './auth'
import { logger } from './logger'
import { promptAction, router } from '@kit.ArkUI'

const instance = axios.create({
  baseURL: 'https://api-harmony-teach.itheima.net/hm/',
  timeout: 10000
})

// 请求拦截器
instance.interceptors.request.use((config: InternalAxiosRequestConfig) => {
  // 每个请求会执行
  const user = auth.getUser()
  if (user.token) {
    config.headers.Authorization = `Bearer ${user.token}`
  }
  return config
}, (err: AxiosError) => {
  return Promise.reject(err)
})

// 伪代码：痛点 获取数据层级多、泛型传递麻烦
// interface HmRes {
//   code: number
//   massage: string
//   data: string[]
// }
// interface HmReq {
//   page: number
// }
// instance<null, AxiosResponse<HmRes,null>, HmReq>({
//   method: 'post',
//   data: {
//     page: 100
//   }
// }).then(res => {
//   res.data.data
// })

// 响应拦截器
instance.interceptors.response.use((res: AxiosResponse) => {
  // 返回的数据，是将来请求得到的数据
  if (res.data.code === 10000) {
    logger.debug('REQ_SUCCESS', JSON.stringify(res.data.data))
    return res.data.data
  }
  logger.error('REQ_ERROR', JSON.stringify(res.data))
  return Promise.reject(res.data)
}, (err: AxiosError) => {
  logger.error('REQ_ERROR', JSON.stringify(err))
  // 处理token失效
  if (err.response?.status === 401) {
    auth.setUser({} as User)
    router.pushUrl({
      url: 'pages/LoginPage'
    }, router.RouterMode.Single)
    promptAction.showToast({ message: '登录失效' })
  }
  return Promise.reject(err)
})


class HttpClient {
  // 需求：响应数据类型+请求参数类型
  request<Res, Req = Object>(config: AxiosRequestConfig<Req>) {
    return instance <null, Res, Req>(config)
  }
}

export const httpClient = new HttpClient()