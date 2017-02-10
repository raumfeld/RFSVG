# RFSVG

[![Build Status](https://travis-ci.org/raumfeld/RFSVG.svg?branch=master)](https://travis-ci.org/raumfeld/RFSVG)
[![codecov](https://codecov.io/gh/raumfeld/RFSVG/branch/master/graph/badge.svg)](https://codecov.io/gh/raumfeld/RFSVG)
[![Version](https://img.shields.io/cocoapods/v/RFSVG.svg?style=flat)](http://cocoapods.org/pods/RFSVG)
[![License](https://img.shields.io/cocoapods/l/RFSVG.svg?style=flat)](http://cocoapods.org/pods/RFSVG)
[![Platform](https://img.shields.io/cocoapods/p/RFSVG.svg?style=flat)](http://cocoapods.org/pods/RFSVG)

A library for easier use and reuse of SVG files. Maintains a cache of rasterized SVG images to minimize the need to re-parse and re-render the SVG file every time it needs to be displayed.

## Usage

API is available through `UIKit` class extensions such as `UIImageView`, `UIButton` and similar by passing in a name of the svg file and size. The rest is done automatically.

### Examples

`UIImageView`

```
let imageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 100))
imageView.setImageFromSVG("unicorn")
```

`UIButton`

```
let button = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 100))
button.setImageFromSVG("unicorn", for: .normal)
```


## Under the hood

`RFSVG` uses [PocketSVG](https://github.com/pocketsvg/PocketSVG) for SVG parsing and rendering. It renders the SVG as `CALayer` then takes a "screenshot" of it. The performance should be checked against the latest APIs and recommendations available from [Apple](https://developer.apple.com/library/content/qa/qa1817/_index.html). Since parsing, rendering and taking a snapshot of an image is expensive and images are often reused, a combination of in-memory and disk cache is employed for efficiency.

### In-memory cache

After being requested to be rendered from SVG an image is **temporarily** cached in an in-memory `NSCache`. Temporarily meaning it will get removed from the in-memory cache if it has been saved to disk. However, a scenario can happen where user is out of disk space. In that case it might stay in memory as long as the application is running or until the application receives a low memory warning.

### Disk cache

`RFSVGCache` singleton deletes and recreates a cache folder on every start. After image has been cached in memory, a representing file is written to the folder asynchronously. Since writing files is async, `RFSVGCache ` also monitors the contents of the cache folder for added files. This is how the in-memory images get purged from the in-memory cache: every time a change in directory is observed it gets checked against in-memory cache and image(s) are cleared from in-memory cache if their corresponding file representation is found.

## Caveats

[PocketSVG](https://github.com/pocketsvg/PocketSVG) isn't a complete implementation of SVG specification and at the time of writing, no such complete library exists for iOS. Most of the problems with SVGs rendering incorrectly have so far been solved by [optimizing](https://github.com/svg/svgo) SVGs.

## Requirements

* Xcode 8.2
* Swift 3
* iOS 9.0 and above

## License

RFSVG is available under the MIT license. See the LICENSE file for more info.

This project includes a svg file "Invisible Pink Unicorn black" [by User:Kontos (derivative of Image:Invisible Pink Unicorn.svg) [GFDL (http://www.gnu.org/copyleft/fdl.html) or CC-BY-SA-3.0 (http://creativecommons.org/licenses/by-sa/3.0/)], via Wikimedia Commons](https://commons.wikimedia.org/wiki/File%3AInvisible_Pink_Unicorn_black.svg)
