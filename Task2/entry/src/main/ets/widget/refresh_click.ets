@Component
export struct RefreshComponent {
  @BuilderParam
  itemLayout?: (item: Object, index: number) => void; // 列表项布局函数
  @Watch("notifyRefreshingChanged")
  @Link refreshing: boolean; // 刷新状态
  @Link dataSet: Array<Object> // 数据集
  onRefresh?: () => void; // 刷新时的回调函数
  onStatusChanged?: (status: RefreshStatus) => void; // 状态改变时的回调函数
  @Prop private title: string = '点击刷新';   // 刷新按钮标题
  private refreshStatus: RefreshStatus = RefreshStatus.Inactive; // 刷新状态
  private listScroller: Scroller = new Scroller(); // 列表滚动器

  private notifyRefreshingChanged() {
    if (this.refreshing) {
      this.showRefreshingStatus(); // 显示正在刷新的状态
    } else {
      this.finishRefresh(); // 完成刷新
    }
  }
//构建刷新按钮
  @Builder RefreshBUTTON() {
    Row() {
      if (this.refreshing) {
        Text('🔄').fontSize(20).margin({ right: 10 });        // 加载动画
      }
      Text(this.refreshing ? '正在刷新...' : this.title)        //显示正在刷新...
        .fontSize(20)                                         //字体大小为20
        .textAlign(TextAlign.Center)                          //文本居中对齐
        .backgroundColor('#cccccc')                           //按钮背景颜色为白色
        .borderRadius(10)                                     //按钮圆角半径为10
        .padding({ top: 10, bottom: 10, left: 20, right: 20 })//设置按钮内边距
        .onClick(() => {                                      //绑定点击事件
          this.setRefreshStatus(RefreshStatus.Refresh);
          this.notifyRefreshStart();
        });
    }
  }
//构建组件的主要布局
  build() {
    Column() {
      this.RefreshBUTTON()    //添加刷新按钮
      Column() {
        List({scroller: this.listScroller}) { // 创建列表
          if (this.dataSet) { // 如果数据集存在
            ForEach(this.dataSet, (item: Object, index: number) => { // 遍历数据集
              ListItem() {
                if (this.itemLayout) { // 如果有项布局函数
                  this.itemLayout(item, index) // 调用项布局函数
                }
              }
              .width("100%") // 每个列表项宽度占满100%
            }, (item: Object, index: number) => item.toString()) // 列表项的唯一标识
          }
        }
        .width("100%") // 列表宽度占满100%
        .height("100%") // 列表高度占满100%
        .edgeEffect(EdgeEffect.None) // 无边缘效果
        .id('screen')
      }
      .width("100%") // 内部列宽度占满100%
      .layoutWeight(1) // 使用布局权重
      .backgroundColor(Color.White) // 背景颜色
    }
    .width("100%") // 外层列宽度占满100%
    .height("100%") // 外层列高度占满100%
  }
  // 组件即将出现时调用
  aboutToAppear() {
    if (this.refreshing) {
      this.showRefreshingStatus(); // 如果正在刷新，显示刷新状态
    }
  }
  // 显示正在刷新的状态
  private showRefreshingStatus() {
    this.setRefreshStatus(RefreshStatus.Refresh); // 设置刷新状态为正在刷新
  }
  // 设置刷新状态
  private setRefreshStatus(status: RefreshStatus) {
    this.refreshStatus = status; // 更新刷新状态
    this.refreshing = (status == RefreshStatus.Refresh); // 更新是否正在刷新
    this.notifyStatusChanged(); // 通知状态改变
  }
  // 通知状态改变
  private notifyStatusChanged() {
    if (this.onStatusChanged) {
      this.onStatusChanged(this.refreshStatus); // 调用状态改变回调函数
    }
  }
  // 通知刷新开始
  private notifyRefreshStart() {
    if (this.onRefresh) {
      this.onRefresh(); // 调用刷新回调函数
    }
  }
  // 完成刷新
  private finishRefresh(): void {
    this.setRefreshStatus(RefreshStatus.Done); // 设置刷新状态为完成
    setTimeout(() => { // 延迟1500毫秒
    }, 1500);
  }



  private resetRefreshStatus() {
    this.setRefreshStatus(RefreshStatus.Inactive); // 设置刷新状态为不活动
  }

}