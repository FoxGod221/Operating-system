import {RefreshList} from "../widget/refresh_list"
import router from '@ohos.router';   //调用router组件用来进行页面跳转

//跳转至新页面函数 利用router组件
function JumptoNew():void{
  router.pushUrl({
    url: 'pages/NewPage',  // 打开新页面 指定新页面路径
  },router.RouterMode.Standard,(err) => {       //设置跳转模式 选择标准模式
    if (err) {
      console.error(`Invoke pushUrl failed, code is ${err.code}, message is ${err.message}`);   //如果跳转发生错误 进行报错
      return;
    }
    console.info('Invoke pushUrl succeeded.');
  }
  )

}
@Entry @Component struct ArkUIClubRefreshListTest {

  @State dataSet: Array<string> = [];
  @State refreshing: boolean = false;
  @State count: number = 0;                      // 状态数据

  @Builder itemLayout(item: Object, index: number) {
    Text("item：" + item + ", index: " + index)
      .width('100%')
      .height(100)
      .margin({top: 10})
      .fontSize(16)
      .textAlign(TextAlign.Center)
      .borderRadius(10)
      .backgroundColor('#bbccaa')
  }

  build() {
    Column() {
      Column() {
        RefreshList({
          refreshing: $refreshing,
          dataSet: $dataSet,
          itemLayout: (item: Object, index: number) => {
            this.itemLayout(item, index);
          },
          onRefresh: () => {
            this.doRefresh();
          },
          onStatusChanged: (status) => {
            console.log("current status: " + status);
          }
        })

      }
      .width("100%")
      .layoutWeight(1)
      // Text(this.count.toString())                // 显示文本
      //   .fontSize(50)                            // 文字大小
      //   .margin(50)                              // 外边距
      //   .size({width:30, height: 30})   // 控件大小
      Button('Next')                                // 显示Next按钮 用于跳转到新页面
        .size({width: 80, height: 50})           // 按钮大小
        .fontSize(15)                            // 按钮文字大小
        .margin(50)
        .backgroundColor('#aabbcc')
        .onClick(() => {                         // 按钮点击事件
          this.doRefresh()                    //调用刷新函数
          JumptoNew()                         //执行跳转函数

        })
    }
    .width("100%")
    .width('100%')
  }

  aboutToAppear() {
    this.initDataSet(0, 5);
  }

  private doRefresh() {
    setTimeout(() => {
      console.log("finish refresh")
      this.initDataSet((Math.random() * 100), 5);
      this.refreshing = false;
    }, 2500);
  }

  private initDataSet(start: number, count: number) {
    let dataSet = new Array<string>();
    for (let i = 0; i < count; i++) {
      dataSet.push((i + start).toFixed(2));
    }
    this.dataSet = dataSet;
  }

}