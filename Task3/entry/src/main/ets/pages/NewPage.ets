// 第二个页面
import router from '@ohos.router';
@Entry @Component struct Index  {

  build() {
    Column({space: 10}) {

      Text('Designed by:'+' Wentao Ding\n'+ 'Yifan Lin\n'+'Weimin Hu') //该页面展示设计这
        .fontSize(30)
        .width('100%')
        .textAlign(TextAlign.Center)  //居中显示
      Button('Back')      //返回按钮组件
        .onClick(() => {
          router.back();              // 返回上一页
        })
    }
    .size({width: '100%', height: '100%'})
  }
}