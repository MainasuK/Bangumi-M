PPCopiableLabel
===============

A simple subclass of UILabel that allows users to copy text with a long press. Handles
highlighting the label as needed.

![](demo.gif)

`PPCopiableLabel` can be used as a drop-in replacement for `UILabel`. You can simply
change the custom class of any `UILabel` in Interface Builder, and now that label will
have the ability to display the Copy menu when pressed for a second.

![](ib_custom_class.png)

While it displays the menu, the label changes to _highlighted_ state, so you can easily
customize its appearance with `UILabel`'s `highlightedTextColor` property, or within
Interface Builder, as shown in the demo.

![](ib_highlighted_color.png)

    label.highlightedTextColor = [UIColor redColor];

If no highlight color is specified, `PPCopiableLabel` takes over the label's `tintColor`,
which is blue by default on iOS 7.

## Installation

Install via [Cocoapods](http://cocoapods.org/). Here's a sample `Podfile`:

    pod 'PPCopiableLabel'

Alternatively, just drop the two files (`PPCopiableLabel.m` and `PPCopiableLabel.h`) into your project tree.

## Contact

Vikram Kriplaney

- http://github.com/markiv
- http://twitter.com/krips
- vikram@local.ch | vikram@iphonso.com

## License

PPCopiableLabel is available under the MIT license. See the LICENSE file for more info.
