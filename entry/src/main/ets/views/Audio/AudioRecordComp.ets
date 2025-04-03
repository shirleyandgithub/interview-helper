import { media } from '@kit.MediaKit'
import { fileIo } from '@kit.CoreFileKit'
import { AudioBoComp } from './AudioBoComp'
import { InterviewAudioItem } from '../../commons/utils/audioDB'
import dayjs from 'dayjs'
import { auth } from '../../commons/utils/auth'

@Component
export struct AudioRecordComp {
  @StorageProp('bottomHeight') bottomHeight: number = 0
  avRecorder?: media.AVRecorder
  fd?: number
  filePath?: string
  timer?: number
  @State maxAmplitude: number = 0
  @State isRecording: boolean = false
  // 录音完毕
  onRecordEnd: (item: InterviewAudioItem) => void = () => {}


  async startRecord() {
    // 1. 准备一个文件接收录音
    const ctx = getContext(this)
    const filePath = ctx.filesDir + '/' + Date.now() + '.m4a'
    this.filePath = filePath
    const file = fileIo.openSync(filePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE)
    this.fd = file.fd
    // 2. 准备路由配置对象
    const config: media.AVRecorderConfig = {
      audioSourceType: media.AudioSourceType.AUDIO_SOURCE_TYPE_MIC,
      profile: {
        audioBitrate: 100000, // 音频比特率
        audioChannels: 2, // 音频声道数
        audioCodec: media.CodecMimeType.AUDIO_AAC, // 音频编码格式，当前只支持aac
        audioSampleRate: 48000, // 音频采样率
        fileFormat: media.ContainerFormatType.CFT_MPEG_4A, // 封装格式，当前只支持m4a
      },
      url: `fd://${file.fd}`
    }
    // 3. 开始录制
    const avRecorder = await media.createAVRecorder()
    await avRecorder.prepare(config)
    await avRecorder.start()
    this.avRecorder = avRecorder
    // 4. 每100ms获取一下声音振幅
    this.timer = setInterval(async () => {
      this.maxAmplitude = await avRecorder.getAudioCapturerMaxAmplitude()
    }, 100)
    // 5. 开始录音时间
    this.startTime = Date.now()
  }

  startTime: number = Date.now()

  async stopRecord() {
    if (this.avRecorder) {
      clearInterval(this.timer)
      await this.avRecorder.stop()
      await this.avRecorder.release()
      fileIo.closeSync(this.fd)
      this.maxAmplitude = 0
    }
  }

  build() {
    Column() {
      AudioBoComp({ maxAmplitude: this.maxAmplitude })
      Row() {
        Image($r('sys.media.ohos_ic_public_voice'))
          .width(24)
          .aspectRatio(1)
          .fillColor($r('app.color.white'))
          .onClick(async () => {
            // 结束
            if (this.isRecording) {
              await this.stopRecord()
              this.isRecording = false
              // 组织录音对象传给父组件
              const file = fileIo.openSync(this.filePath, fileIo.OpenMode.READ_ONLY)
              const size = fileIo.statSync(file.fd).size // 文件大小
              this.onRecordEnd({
                id: null,
                user_id: auth.getUser().id,
                name: dayjs().format('YYYY年MM月DD日_HH时mm分ss秒'),  // 2024年11月22日_10时20分30秒
                path: this.filePath!,
                duration: Date.now() - this.startTime,
                size: size,
                create_time: Date.now()
              })
            }
            // 开始
            else {
              await this.startRecord()
              this.isRecording = true
            }
          })
      }
      .justifyContent(FlexAlign.Center)
      .height(50)
      .width(50)
      .borderRadius(25)
      .margin({ top: 20 })
      .backgroundColor(this.isRecording ? $r('app.color.common_blue') : $r('app.color.black'))
    }
    .width('100%')
    .height(240)
    .backgroundColor($r('app.color.common_gray_bg'))
    .padding({
      bottom: this.bottomHeight,
      left: 80,
      right: 80,
      top: 20
    })
  }
}