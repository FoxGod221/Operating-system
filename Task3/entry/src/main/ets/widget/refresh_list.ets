import display from '@ohos.display';
// 定义一个常量类，用于存储刷新相关的文本常量
export class Constant {
  static readonly REFRESH_PULL_TO_REFRESH = "下拉刷新"; // 下拉刷新提示
  static readonly REFRESH_UP_TO_REFRESH   = "上拉刷新"; // 上拉刷新提示
  static readonly REFRESH_FREE_TO_REFRESH = "释放立即刷新"; // 释放以立即刷新的提示
  static readonly REFRESH_REFRESHING      = "正在刷新"; // 正在刷新状态提示
  static readonly REFRESH_SUCCESS         = "刷新成功"; // 刷新成功提示
}
// 定义一个组件 RefreshList
@Component
export struct RefreshList {
  @BuilderParam
  itemLayout?: (item: Object, index: number) => void; // 列表项布局函数
  @Watch("notifyRefreshingChanged")
  @Link refreshing: boolean; // 刷新状态
  @Link dataSet: Array<Object> // 数据集
  onRefresh?: () => void; // 刷新时的回调函数
  onStatusChanged?: (status: RefreshStatus) => void; // 状态改变时的回调函数
  // 定义一些私有变量
  private headHeight: number = 55; // 头部高度
  private lastX: number = 0; // 上一次触摸的 X 坐标
  private lastY: number = 0; // 上一次触摸的 Y 坐标
  private downY: number = 0; // 初始触摸 Y 坐标
  private flingFactor: number = 0.75; // 滑动因子
  private touchSlop: number = 2; // 触摸滑动阈值
  private offsetStep: number = 10; // 偏移步长
  private intervalTime: number = 20; // 定时器间隔时间
  private listScrollable: boolean = true; // 列表是否可滚动
  private dragging: boolean = false; // 是否正在拖动
  private refreshStatus: RefreshStatus = RefreshStatus.Inactive; // 刷新状态
  @Watch("notifyOffsetYChanged")
  @State offsetY: number = -this.headHeight; // 当前 Y 偏移量
  @State Y: number = 0; // 当前 Y 偏移量
  @State refreshHeadIcon: Resource = $r("app.media.icon_refresh_down"); // 刷新头部图标
  @State refreshHeadText: string = Constant.REFRESH_PULL_TO_REFRESH; // 刷新头部文本
  @State refreshfootIcon: Resource = $r("app.media.icon_refresh_up"); // 刷新尾部图标
  @State refreshfootText: string = Constant.REFRESH_UP_TO_REFRESH; // 刷新尾部文本
  @State refreshContentH: number = 0; // 刷新内容高度
  @State touchEnabled: boolean = true; // 是否启用触摸
  @State headerVisibility: Visibility = Visibility.None; // 头部可见性
  @State footVisibility: Visibility = Visibility.None; // 头部可见性
  private listScroller: Scroller = new Scroller(); // 列表滚动器
  // 刷新状态改变通知
  private notifyRefreshingChanged() {
    if (this.refreshing) {
      this.showRefreshingStatus(); // 显示正在刷新的状态
    } else {
      this.finishRefresh(); // 完成刷新
    }
  }
  // 偏移量改变通知
  private notifyOffsetYChanged() {
    // 根据偏移量设置头部可见性
    this.headerVisibility = (this.offsetY <= -this.headHeight) ? Visibility.None : Visibility.Visible;
    this.footVisibility = (this.offsetY >= -this.headHeight) ? Visibility.None : Visibility.Visible;
  }
  // 构建头部布局
  @Builder headLayout() {
    Row() {
      Blank() // 占位
      Image(this.refreshHeadIcon) // 刷新图标
        .width(30) // 宽度为30
        .aspectRatio(1) // 保持宽高比
        .objectFit(ImageFit.Contain) // 图片适应方式
      Text(this.refreshHeadText) // 刷新文本
        .fontSize(16) // 字体大小为16
        .width(150) // 宽度为150
        .textAlign(TextAlign.Center) // 文本居中对齐
      Blank() // 占位
    }
    .width("100%") // 宽度占满100%
    .height(this.headHeight) // 高度为头部高度
    .backgroundColor("#44bbccaa") // 背景颜色
    .visibility(this.headerVisibility) // 头部可见性
    .position({
      x: 0, // X 位置
      y: this.offsetY // Y 位置
    })
  }
  @Builder footLayout() {
    Row() {
      Blank() // 占位
      Image(this.refreshfootIcon) // 刷新图标
        .width(30) // 宽度为30
        .aspectRatio(1) // 保持宽高比
        .objectFit(ImageFit.Contain) // 图片适应方式
      Text(this.refreshfootText) // 刷新文本
        .fontSize(16) // 字体大小为16
        .width(150) // 宽度为150
        .textAlign(TextAlign.Center) // 文本居中对齐
      Blank() // 占位
    }
    .width("100%") // 宽度占满100%
    .height(this.headHeight) // 高度为头部高度
    .backgroundColor("#44bbccaa") // 背景颜色
    .visibility(this.footVisibility) // 头部可见性
    .position({
      x: 0, // X 位置
      y: this.offsetY + this.headHeight + this.Y// Y 位置
    })
  }
  // 构建组件的主要布局
  build() {
    Column() {
      this.headLayout() // 添加头部布局
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
      .position({
        x: 0, // X 位置
        y: this.offsetY + this.headHeight // Y 位置
      })
      this.footLayout()
    }
    .width("100%") // 外层列宽度占满100%
    .height("100%") // 外层列高度占满100%
    .enabled(this.touchEnabled) // 根据触摸状态启用或禁用
    .onAreaChange((oldArea, newArea) => { // 区域变化事件
      console.log("Refresh height: " + newArea.height); // 输出刷新高度
      this.Y = Number(newArea.height)
      this.refreshContentH = Number(newArea.height); // 更新刷新内容高度
    })
    .clip(true) // 启用裁剪
    .onTouch((event) => { // 触摸事件处理
      if (event.touches.length != 1) { // 如果触摸点不为1
        this.logD("TOUCHES LENGTH INVALID: " + JSON.stringify(event.touches)) // 输出日志
        event.stopPropagation(); // 阻止事件传播
        return
      }
      switch (event.type) { // 根据触摸事件类型处理
        case TouchType.Down: // 触摸开始
          this.onTouchDown(event); // 处理触摸开始事件
          break;
        case TouchType.Move: // 触摸移动
          this.onTouchMove(event); // 处理触摸移动事件
          break;
        case TouchType.Up: // 触摸结束
        case TouchType.Cancel: // 触摸取消
          this.onTouchUp(event); // 处理触摸结束事件
          break;
      }
      event.stopPropagation(); // 阻止事件传播
    })
  }
  // 设置刷新状态
  private setRefreshStatus(status: RefreshStatus) {
    this.refreshStatus = status; // 更新刷新状态
    this.refreshing = (status == RefreshStatus.Refresh); // 更新是否正在刷新
    this.touchEnabled = (status != RefreshStatus.Refresh && status != RefreshStatus.Done); // 根据状态更新触摸启用状态
    this.notifyStatusChanged(); // 通知状态改变
  }
  // 检查是否可以刷新
  private canRefresh() {
    return this.listScroller.currentOffset().yOffset == 0; // 判断当前偏移量是否为0
  }
  // 处理触摸开始事件
  private onTouchDown(event: TouchEvent) {
    this.lastX = event.touches[0].screenX; // 记录触摸的 X 坐标
    this.lastY = event.touches[0].screenY; // 记录触摸的 Y 坐标
    this.downY = this.lastY; // 记录初始触摸 Y 坐标
    this.dragging = false; // 设置为不在拖动状态
    this.listScrollable = true; // 列表可滚动
    this.logD("Touch DOWN: " + event.touches[0].screenX.toFixed(2) + " x " + event.touches[0].screenY.toFixed(2) + ", offset: " + this.offsetY); // 输出触摸开始日志
  }
  // 处理触摸移动事件
  private onTouchMove(event: TouchEvent) {
    let currentX = event.touches[0].screenX; // 当前触摸的 X 坐标
    let currentY = event.touches[0].screenY; // 当前触摸的 Y 坐标
    let deltaX = currentX - this.lastX; // X 坐标变化量
    let deltaY = currentY - this.lastY; // Y 坐标变化量
    if (this.dragging) { // 如果正在拖动
      this.logD("offsetY: " + this.offsetY.toFixed(2) + ",  head: " + (-this.headHeight));
      if (deltaY < 0) { // 手势向上拖动
        this.logD("手指向上拖动中")
        if (this.canRefresh()) { // 如果可以刷新
          this.offsetY = this.offsetY + px2vp(deltaY) * this.flingFactor; // 更新偏移量
          this.listScrollable = false; // 禁止列表滚动
        } else {
          this.listScrollable = true; // 允许列表滚动
        }
      } else { // 手势向下拖动
        this.logD("手指向下拖动中")
        if (this.canRefresh()) { // 如果可以刷新
          this.offsetY = this.offsetY + px2vp(deltaY) * this.flingFactor; // 更新偏移量
          this.listScrollable = false; // 禁止列表滚动
        } else {
          this.listScrollable = true; // 允许列表滚动
        }
      }
      this.lastX = currentX; // 更新上一次触摸的 X 坐标
      this.lastY = currentY; // 更新上一次触摸的 Y 坐标
    } else { // 如果未开始拖动
      if (Math.abs(deltaX) < Math.abs(deltaY) && Math.abs(deltaY) > this.touchSlop) { // 判断是否符合拖动条件
        if (this.canRefresh()) { // 如果向下滑动并且可以刷新
          this.dragging = true; // 设置为正在拖动状态
          this.listScrollable = false; // 禁止列表滚动
          this.lastX = currentX; // 更新上一次触摸的 X 坐标
          this.lastY = currentY; // 更新上一次触摸的 Y 坐标
          this.logD("Touch MOVE: 手指滑动，达到了拖动条件") // 输出日志
        }
      }
    }
    if(this.dragging) { // 如果正在拖动
      if (currentY >= this.downY) { // 如果当前 Y 坐标大于初始触摸 Y 坐标
        if (this.offsetY >= 0 || (this.headHeight - Math.abs(this.offsetY)) > this.headHeight * 4 / 5) { // 判断是否达到下拉刷新条件
          this.refreshHeadText = Constant.REFRESH_FREE_TO_REFRESH; // 更新头部文本
          this.refreshHeadIcon = $r("app.media.icon_refresh_up"); // 更新头部图标
          this.setRefreshStatus(RefreshStatus.OverDrag); // 设置刷新状态为过度拖动
        } else{
          this.refreshHeadText = Constant.REFRESH_PULL_TO_REFRESH; // 更新头部文本
          this.refreshHeadIcon = $r("app.media.icon_refresh_down"); // 更新头部图标
          this.setRefreshStatus(RefreshStatus.Drag); // 设置刷新状态为拖动
        }
      }else {
        if(this.offsetY < -2*this.headHeight){
          this.refreshfootText = Constant.REFRESH_FREE_TO_REFRESH; // 更新头部文本
          this.refreshfootIcon = $r("app.media.icon_refresh_down"); // 更新头部图标
          this.setRefreshStatus(RefreshStatus.OverDrag); // 设置刷新状态为过度拖动
        }else {
          this.refreshfootText = Constant.REFRESH_FREE_TO_REFRESH; // 更新头部文本
          this.refreshfootIcon = $r("app.media.icon_refresh_down"); // 更新头部图标
          this.setRefreshStatus(RefreshStatus.Drag); // 设置刷新状态为拖动
        }
      }
    }
    // this.logD("Touch MOVE: " + event.touches[0].screenX + " x " + event.touches[0].screenY + ", offset: " + this.offsetY);
  }
  // 处理触摸结束事件
  private onTouchUp(event: TouchEvent) {
    this.logD("Touch   UP: " + event.touches[0].screenX.toFixed(2) + " x " + event.touches[0].screenY.toFixed(2) + ", offset: " + this.offsetY);
    if (this.dragging) { // 如果正在拖动
      // 手指最终向下滑动
      if (this.offsetY >= 0 || (this.headHeight - Math.abs(this.offsetY)) > this.headHeight * 4 / 5) { // 判断是否达到下拉刷新条件
        this.logD("Touch   UP: 最终达到下拉刷新条件") // 输出日志
        this.refreshHeadIcon = $r("app.media.icon_refresh_loading"); // 更新头部图标
        this.refreshHeadText = Constant.REFRESH_REFRESHING; // 更新头部文本
        this.setRefreshStatus(RefreshStatus.Refresh); // 设置刷新状态为正在刷新
        this.scrollToTop(); // 滚动到顶部
        this.notifyRefreshStart(); // 通知刷新开始
      } else if(this.offsetY < -2*this.headHeight){
        this.logD("Touch   UP: 最终达到上拉刷新条件") // 输出日志
        this.refreshfootIcon = $r("app.media.icon_refresh_loading"); // 更新头部图标
        this.refreshfootText = Constant.REFRESH_REFRESHING; // 更新头部文本
        this.setRefreshStatus(RefreshStatus.Refresh); // 设置刷新状态为正在刷新
        this.scrollToBottom(); // 滚动到顶部
        this.notifyRefreshStart(); // 通知刷新开始
      } else {
        this.logD("Touch   UP: 最终未达到刷新条件") // 输出日志
        this.refreshHeadIcon = $r("app.media.icon_refresh_down"); // 更新头部图标
        this.refreshHeadText = Constant.REFRESH_PULL_TO_REFRESH; // 更新头部文本
        this.refreshfootIcon = $r("app.media.icon_refresh_up"); // 更新头部图标
        this.refreshfootText = Constant.REFRESH_UP_TO_REFRESH; // 更新头部文本
        this.setRefreshStatus(RefreshStatus.Drag); // 设置刷新状态为拖动
        this.scrollByTop(); // 滚动到头部
      }
    }
  }
  // 滚动到顶部
  private scrollToTop() {
    this.offsetY = 0; // 设置偏移量为0
  }
  private scrollToBottom() {
    this.offsetY = -2*this.headHeight; // 设置偏移量为0
  }
  // 滚动到头部
  private scrollByTop() {
    if (this.offsetY != -this.headHeight) { // 如果偏移量不等于头部高度的负值
      this.logD("scrollByTop() start, offsetY: " + this.offsetY.toFixed(2)); // 输出日志
      let intervalId = setInterval(() => { // 设置定时器
        if(this.offsetY <= -this.headHeight) { // 如果偏移量小于等于头部高度的负值
          this.resetRefreshStatus(); // 重置刷新状态
          clearInterval(intervalId); // 清除定时器
          this.logD("scrollByTop() finish, offsetY: " + this.offsetY.toFixed(2)); // 输出日志
        } else {
          this.offsetY = ((this.offsetY - this.offsetStep) < -this.headHeight) ? (-this.headHeight) : (this.offsetY - this.offsetStep); // 更新偏移量
        }
      }, this.intervalTime); // 每隔 intervalTime 毫秒执行一次
    } else {
      this.logD("scrollByTop(): already scrolled to top edge") // 输出日志
    }
  }
  // 重置刷新状态
  private resetRefreshStatus() {
    this.offsetY = -this.headHeight; // 设置偏移量为头部高度的负值
    this.refreshHeadIcon = $r("app.media.icon_refresh_down"); // 更新头部图标
    this.refreshHeadText = Constant.REFRESH_PULL_TO_REFRESH; // 更新头部文本
    this.refreshfootIcon = $r("app.media.icon_refresh_up"); // 更新头部图标
    this.refreshfootText = Constant.REFRESH_UP_TO_REFRESH; // 更新头部文本
    this.setRefreshStatus(RefreshStatus.Inactive); // 设置刷新状态为不活动
  }
  // 完成刷新
  private finishRefresh(): void {
    this.refreshHeadText = Constant.REFRESH_SUCCESS; // 更新头部文本为刷新成功
    this.refreshHeadIcon = $r("app.media.icon_refresh_success"); // 更新头部图标为成功图标
    this.refreshfootText = Constant.REFRESH_SUCCESS; // 更新头部文本为刷新成功
    this.refreshfootIcon = $r("app.media.icon_refresh_success"); // 更新头部图标为成功图标
    this.setRefreshStatus(RefreshStatus.Done); // 设置刷新状态为完成
    setTimeout(() => { // 延迟1500毫秒后滚动到头部
      this.scrollByTop();
    }, 1500);
  }
  // 组件即将出现时调用
  aboutToAppear() {
    if (this.refreshing) {
      this.showRefreshingStatus(); // 如果正在刷新，显示刷新状态
    }
  }
  // 显示正在刷新的状态
  private showRefreshingStatus() {
    this.offsetY = 0; // 设置偏移量为0
    this.refreshHeadIcon = $r("app.media.icon_refresh_loading"); // 更新头部图标为加载图标
    this.refreshHeadText = Constant.REFRESH_REFRESHING; // 更新头部文本为正在刷新
    this.refreshfootIcon = $r("app.media.icon_refresh_loading"); // 更新头部图标为加载图标
    this.refreshfootText = Constant.REFRESH_REFRESHING; // 更新头部文本为正在刷新
    this.setRefreshStatus(RefreshStatus.Refresh); // 设置刷新状态为正在刷新
  }
  // 通知刷新开始
  private notifyRefreshStart() {
    if (this.onRefresh) {
      this.onRefresh(); // 调用刷新回调函数
    }
  }
  // 通知状态改变
  private notifyStatusChanged() {
    if (this.onStatusChanged) {
      this.onStatusChanged(this.refreshStatus); // 调用状态改变回调函数
    }
  }
  // 日志输出函数
  private logD(msg: string) {
    console.log(msg + ", canRefresh: " + this.canRefresh() + ", dragging: " + this.dragging + ", listScrollable:" + this.listScrollable + ", refreshing: " + this.refreshing);
  }
}