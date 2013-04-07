AnimatedGaussianBlur
===============================

Poor man's animated gaussian blur.

In this project I have gaussian blur filters at different levels applied to the snapshot of an image consecutively to simulate an animated blur view transition effect. To keep things simple, the blurred images are stored in an NSArray and the animation is achieved simply by snapping a UIImageView on top of the view and setting its animationImages property to the array. I knew this approach was going to be slow - I wanted to know bad it might be.

In viewDidLoad, a snapshot of the background view is taken, and 15 copies of the image are made with each blurred to a varying level. At 0.5s, 15 images give a smooth enough frame rate. Three different filter techniques - GPUImageFastBlurFilter, GPUImageGaussianBlurFilter and CIGaussianBlur, were evaluated for performance comparison.  


Time taken for preparing the rendered images 
---
* CIGaussianBlur - 7548.0 ms
* GPUImageGaussianBlurFilter - 7377.0 ms 
* GPUImageFastBlurFilter - 639.0 ms

Done on a MBP 2.6 GHz i7 16GB

License
---
MIT (https://github.com/kenshin03/RouletteWheelCollectionViewDemo/blob/master/LICENSE)


Screenshot
---
![Screenshot](cover_image.png)


