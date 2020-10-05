# PhotoHunt
A small app to search for images from different image providers (

## Capabilities
- Search for images using 3 different APIs
- Apply a filter to select the API to search from
- At least one API will always on

## Utilizes
- Concurrent Queue: using concurrent queue to download images concurrently for less wait time and better user experience
   - DispatchQueue
   - DispatchWorkItem
   - Custom DispatchQueue
- URLSession: using URLComponents and URLQueryItem to create URLRequest with dynamic parameters and headers
- Delegation
- SwiftLint is enabled to ensure clean code

## Images

<p align="center">
  <img src="https://github.com/ngay881855/PhotoHunt/blob/main/GIFs/ezgif-PhotoHunt_1.gif" height="600" />
  <img src="https://github.com/ngay881855/PhotoHunt/blob/main/GIFs/ezgif-PhotoHunt_2.gif" height="600" />
</p>
