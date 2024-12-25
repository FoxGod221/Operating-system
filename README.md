# 组内分工

| 姓名   | 分工                               |
| ------ | ---------------------------------- |
| 丁文涛 | 开发上下拉刷新功能并填写设计文档   |
| 林逸帆 | 开发刷新当前页组件并填写设计文档   |
| 胡伟民 | 开发路由跳转刷新组件并填写设计文档 |




# 上下拉刷新设计文档

## 一、设计目标：

1. 实现下拉刷新与上拉刷新功能，具体表现为鼠标拖动页面上拉或者下拉将触发刷新
2. 为刷新时每个阶段作出对应动画，并给出文字表示
3. 适配不同分辨率的页面

## 二、设计思路

### 1 定义刷新任务
​		因为作业中没有具体提到如何实现刷新以及刷新的具体表现，因此我们设计了一个简单的应用程序，在界面中显示若干个随机数，在触发刷新条件后，运行刷新动画，进行一段时间的延时来模拟刷新，在延时结束以后重新加载随机数来表现刷新进行完成。

### 2 设计刷新过程

​		参考常见的手机app的刷新过程，我们设计的上下拉刷新的过程也是一样，首先需要使用者鼠标拖动上拉或者下拉，若是下拉，则页面整体下移，在页面顶部出现”下拉刷新“字样，显示刷新图标，如果过度下拉则显示”释放立即刷新“字样，显示向上的箭头图标，释放后页面移动到顶部进行刷新，显示刷新图样并出现”正在刷新“字样，延时后出现”刷新成功“字样，显示成功图标。如果下拉不彻底则不进行刷新。

​		若是上拉，则页面整体上移，在页面底部出现”上拉刷新“字样，显示刷新图标，如果过度上拉则显示”释放立即刷新“字样，显示向下的箭头图标，释放后页面移动到底部进行刷新，显示刷新图样并出现”正在刷新“字样，延时后出现”刷新成功“字样，显示成功图标。如果上拉不彻底则不进行刷新。

### 3 设计页面

​		我们设计的页面整体框架如下：

<img src="C:\Users\20123\Desktop\页面设计.png" style="zoom: 40%;" />

​		如上图所示，页面被分为了三部分，页面主体是页面正常显示的部分，上面有一个含有若干随机数显示的列表，页面头部和页面底部在常态下是不显示的，在进行鼠标拖动进入刷新过程后会对应显示，下拉刷新显示页面头部，上拉刷新显示页面顶部。

## 三、代码实现

### 1 新建刷新组件文件

​		首先，在项目的entry\src\main\ets文件夹下新建一个widget文件夹，在这个文件夹中新建一个refresh_list.ets文件，在该文件中完成上下拉刷新组件的功能。

### 2 构建页面

​		由上述知整体的页面框架分为了三个部分，

```typescript
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
  //构建底部布局
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
```

​		页面的头部我们设计为宽度占满，高度为55的区域，可以显示图像和文本，文本居中对齐，字体大小为16，图像宽度为30，统一存储在entry\src\main\resources\base\media文件夹中，页面的y偏移位置为-55（即头部区域高度的负值），这样在没有进行刷新时，页面头部在显示界面的上方，同时我们使用了``` Visibility ```这个属性以设置头部区域的可见性，当页面整体的偏移大于-55时（即进行了下拉），页面头部可见，其他时间不可见，改变页面可见性的代码如下：

```typescript
  // 偏移量改变通知
  private notifyOffsetYChanged() {
    // 根据偏移量设置头部可见性
    this.headerVisibility = (this.offsetY <= -this.headHeight) ? Visibility.None : Visibility.Visible;
    this.footVisibility = (this.offsetY >= -this.headHeight) ? Visibility.None : Visibility.Visible;
  }
```

​		页面底部设计与顶部大致相同，但是页面的偏移量需要特别设计，因为页面底部的偏移量应该是头部区域的高度加上可显示界面的高度，可是在不同分辨率不同大小的显示器上页面大小不同，因此需要先得到显示界面的高度（即``` this.Y ```）才能确定底部的y偏移量。为了程序能适配不同分辨率的屏幕，我们使用了如下方法获取``` this.Y ```：

```typescript
    .onAreaChange((oldArea, newArea) => { // 区域变化事件
      console.log("Refresh height: " + newArea.height); // 输出刷新高度
      this.Y = Number(newArea.height)
      this.refreshContentH = Number(newArea.height); // 更新刷新内容高度
    })
```

​		``` .onAreaChange ```是ArkTS提供的组件区域变化事件，组件区域变化时触发该回调，其中``` oldArea ```与``` newArea ```都是Area类型的数据，用于存储元素所占区域信息，其中的height就代表页面的高度。

### 3 触摸事件处理

​		触摸时间主要调用``` .onAreaChange ```事件，详情请参考ArkTs API文档，这里不再赘述，代码如下：

```typescript
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
    }
```

​		触摸开始时，主要记录触摸点的y坐标，处理触摸移动事件首先判断是否符合拖动条件，如果符合拖动条件就更新偏移量，并对应更新头部或底部区域文本和图标，处理触摸结束事件主要判断是否达到了刷新的条件并对应更新文本与图标，并通知刷新开始，具体代码如下：

```typescript
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
        this.scrollToBottom(); // 滚动到底部
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
  // 滚动到底部
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
```

### 4 模拟刷新

​		通过延时进行模拟刷新，同时对应更改图标和文字

```typescript
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
```



# 单击刷新设计文档

## 一、组件名称：RefreshComponent

## 二、功能描述

该组件是一个可点击的按钮，用于触发刷新操作并显示加载状态。根据 refreshing 状态，动态展示加载动画或按钮标题。

## 三、设计目标

1.点击按钮触发刷新逻辑。

2.点击前显示默认按钮标题；点击后显示加载动画及提示文字“正在刷新...”。

## 四、设计思路

### 1.初始状态：

设置refreshing为false，显示按钮标题。

### 2.点击事件触发:

调用 setRefreshStatus(RefreshStatus.Refresh)，更改为刷新状态。

调用 notifyRefreshStart() 通知刷新开始。

### 3.刷新状态:

设置refreshing为true，显示加载动画和提示文字“正在刷新...”。

### 4.刷新完成:

外部逻辑将 refreshing 设置回 false，恢复按钮标题。

## 五、代码实现

### 1.新建单击刷新组件文件

首先，在项目的entry\src\main\ets文件夹下新建一个widget文件夹，在这个文件夹中新建一个refresh_click.ets文件，在该文件中完成单击刷新组件的功能。

### 2.构建页面

![image-20241224231306738](C:\Users\20123\AppData\Roaming\Typora\typora-user-images\image-20241224231306738.png)

![image-20241224231317278](C:\Users\20123\AppData\Roaming\Typora\typora-user-images\image-20241224231317278.png)

在组件的布局中，我们首先构建了一个刷新按钮，并通过refreshing的状态来进行按钮状态切换，最后绑定OnClick事件来触发刷新状态。

其次，我们构建了一个列表布局，并用item和index来分别表示内容和索引。

### 3.刷新逻辑

在组件加载时检查并显示刷新状态；在出发刷新操作时通知刷新开始，并且设置刷新状态为刷新中，在刷新完成后延迟一段时间设置刷新状态为完成

![image-20241224231337565](C:\Users\20123\AppData\Roaming\Typora\typora-user-images\image-20241224231337565.png)

![image-20241224231352776](C:\Users\20123\AppData\Roaming\Typora\typora-user-images\image-20241224231352776.png)

## 六、系统API介绍

| **名称**                                           | **功能描述**                                                 |
| -------------------------------------------------- | ------------------------------------------------------------ |
| onRefresh?: () => void;                            | 当用户进行click动作时，onRefresh被触发，执行自定义的刷新逻辑 |
| onStatusChanged?: (status: RefreshStatus) => void; | 当刷新状态发生变化时（例如从正在刷新、刷新完成等），onStatusChanged会被触发，允许开发者处理不同的刷新状态。  RefreshStatus的取值包括：Refresh,Done. |



# 路由跳转刷新组件设计文档

1. 整体设计思路：使用ArkUI框架提供的router模块，这个模块通过不同的 url地址，可以方便地进行页面路由。而router提供了两种跳转模式，一种是跳转到新页面后销毁当前页面，另一种是跳转到新页面后保留当前页面，同时提供返回当前页面接口，我们在新页面设计一个按钮组件，在其触发事件中调用返回旧页面函数。同时在进行跳转时调用任务一中已经编写的刷新页面函数。

2. 当前页面设计：在旧页面（当前页面）中，我们保留任务一中设计的RefreshList组件，用来演示数据的刷新效果。同时再添加一个新的按钮用来作为页面跳转触发。图1是该新增按钮组件的参数设置以及点击触发事件的程序设计，在程序第59到63行对按钮的尺寸等参数进行设置。在第64行设置点击触发事件，在其中调用任务一中实现的doRefresh函数刷新数据，同时调用自定义函数JumptoNew用于跳转到新页面。

![img](file:///C:/Users/20123/AppData/Local/Temp/msohtmlclip1/01/clip_image002.png)

<center>图1 按钮组件部分程序(src/pages/Index.ets)</center>

3. 跳转函数（JumptoNew）实现：如图2所示，我们首先引入router模块。在该函数中调用pushUrl函数，函数形参为新页面的url地址，在这里是新页面的保存地址。在第8行程序中设置了跳转模式，这里选择的标准模式是前文提到的跳转同时保留当前页面。第9到13行设置了一些有关跳转失败的报错信息设置。

![img](file:///C:/Users/20123/AppData/Local/Temp/msohtmlclip1/01/clip_image004.png)

<center>图2 JumptoNew函数程序</center>

4. 新页面设计：如图3所示，在新页面中我们做了简单的设计与展示，该页面与旧页面同位于src目录下的pages目录。在新页面中我们设计了文本组件，显示了我们三位组员的姓名，同时也是整体程序的设计者。在第12行定义了一个按钮，通过点击触发返回操作，返回操作调用的是router组件的back方法，可以直接返回到原本页面。

![img](file:///C:/Users/20123/AppData/Local/Temp/msohtmlclip1/01/clip_image006.png)

<center> 图3 NewPage程序设计</center>
