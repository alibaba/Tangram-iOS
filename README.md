# Tangram - iOS

Tangram is a UI Framework for building a fast and dynamic ScrollView. 
 
The system requirement for Tangram is iOS 7.0+

[中文站点](http://tangram.pingguohe.net)

Tips: If you get ``[!] Unable to find a specification for `LazyScroll` `` when executed `pod install`, you can try to update `ruby` to `2.3.0` or higher and update `CocoaPods` to `1.0.0` or higher . If it doesn't work , you can try to reset or update CocoaPods master repo again . 

## Feature

- Two platform support (iOS & Android, See Tangram-Android in Github for Android Version)
- Fast Generate View by JSON Data , provide default parser.
- Easily control the reuseability of views 
- Provide multiple built-in layouts 
- Custom layout style (by JSON Data or code)
- High scroll performance (Base on [LazyScrollView](https://github.com/alibaba/LazyScrollView))
- Extendable API

## Advantage

Compare to system standard controls(like UICollectionView, GridView), 
the advantages of Tangram are : 

### Easily control 'layout' selected for elements(cells). 

![](https://gw.alicdn.com/tps/TB1c7HuPVXXXXaGaXXXXXXXXXXX-370-672.gif)

In the picture above, it shows several kinds of layout, Tangram can easily control  
which kind of layout these elements use. You can find its usage in TangramDemo.

### Provide default parser , quick parse JSON to View

JSON to View can be very easy by use our default parser.

You can open `TangramDemo` to see how to tranfer JSON to view.

The default parsers are same in two platform (Android and iOS).

### Provide several kinds of layout 

We provide internal layouts, including:

* FlowLayout (like grid)
* One drag N Layout (N=2/3/4)
* Fix Layout
* Sticky Layout
* Dragable Layout
* PageScroll Layout
* WaterFlow Layout

To See detailed performance of interal layouts , [Click me](https://github.com/alibaba/Tangram-iOS/blob/master/Docs/layoutIndex.md)

## Install

Use Cocoapods to Get latest version of Tangram

```
pod 'Tangram'
```


## Getting Started

- See [Getting Started Guide](https://github.com/alibaba/Tangram-iOS/blob/master/Docs/getting-started.md)
- Or Open project in `TangramDemo` and execute `pod install` to see detail usage.
