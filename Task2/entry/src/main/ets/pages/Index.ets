import {RefreshComponent} from "../widget/refresh_click"

@Entry @Component struct ArkUIClubRefreshClickTest {

  @State dataSet: Array<string> = [];
  @State refreshing: boolean = false;

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
        RefreshComponent({
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
