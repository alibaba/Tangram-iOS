# Layout Index

Type is a layout property in JSON

 ![](https://img.alicdn.com/tfs/TB1o426PVXXXXb_XXXXXXXXXXXX-445-241.png)

## FlowLayout

![](https://img.alicdn.com/tfs/TB1UX3DPVXXXXbsXXXXXXXXXXXX-548-299.png)

|type|Description|
|---|----|
|1|One column|
|2|Two columns|
|3|Three columns|
|4|Four columns|
|9|Five columns|
|27|any column,assign by code or style in JSON|


## 1-n layout (n=2/3/4) 

A large element on the left ，several small element on the right，support assiging ratio of the left and right.

![](https://img.alicdn.com/tfs/TB1UmkEPVXXXXbDXXXXXXXXXXXX-559-239.png)

There are three styles of the layout：

* A large element on the left，one above one below on the right.
* A large element on the left，one above two below on the right.
* A large element on the left，one above three below on the right.

Adjust depend on the count of itemModels in the layout

|type|Description|
|---|----|
|5|One Drag N(N=2/3/4)|

## Drag Layout

The layout can be dragged, auto hit to edges

The No.0 element is in a drag layout.

![](https://img.alicdn.com/tfs/TB1Nv3DPVXXXXcaapXXXXXXXXXX-370-672.gif)

|type|Description|
|---|----|
|7|Drag Layout|

## Fix Layout

Fix at fixed position, or scroll to some position to show

The No.0 element is in a fix layout.

![](https://img.alicdn.com/tfs/TB1tOUDPVXXXXcnaXXXXXXXXXXX-370-672.gif)

|type|Description|
|---|----|
|8|Fix at top|
|23|Fix at bottom|
|28|Scroll to some layout to show and fix at top)|

## Sticky Layout

If the layout hit the top of visible area, it will stick to top edge of visible area.

The No.9 element is in a sticky layout

![](https://img.alicdn.com/tfs/TB1tOUDPVXXXXcnaXXXXXXXXXXX-370-672.gif)

|type|Description|
|---|----|
|21|Stick to top|

## Page Scroll Layout

Suitable for banner, it can auto scrolling , cycle scrolling or linear scrolling

![](https://img.alicdn.com/tps/TB1WOUsOpXXXXbzXFXXXXXXXXXX-373-90.gif)

|type|Description|
|---|----|
|10|Page Scroll Layout|

## Water Flow Layout

![](https://img.alicdn.com/tfs/TB1tDEJPVXXXXXWaXXXXXXXXXXX-375-689.png)

|type|Description|
|---|----|
|25|WaterFlow Layout|
















