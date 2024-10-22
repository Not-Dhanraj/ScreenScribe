# On Screen Ocr app (Alpha)

This Flutter app provides an overlay icon that remains on the screen while navigating other apps or system UI. Upon tapping the icon, the app takes a screenshot of the current screen. It then opens a cropping interface where the user can select a portion of the screenshot. Once the cropping is done, the app extracts text from the selected portion using Optical Character Recognition (OCR) using google ml toolkit.

**Note:** This app is currently in its early alpha phase and may not work as expected in some cases. There are not any optimizations or code structure rn. Please feel free to report issues and contribute to improvements.

## Demo

Check out this video showcasing the working implementation of the app:



![](https://github.com/user-attachments/assets/ecc07e34-e652-49e1-ba71-749d8c332a13)





## Prerequisites

- Flutter
- Android SDK

## Setup

1. Clone the repository:

   ```bash
   git clone https://github.com/Not-Dhanraj/on_screen_ocr.git
   cd on_screen_ocr
   ```

2. Install the required dependencies:

   ```bash
   flutter pub get
   ```

3. Run the app:

   ```bash
   flutter run
   ```

## Early Alpha Disclaimer

This app is in the alpha channel, so some features may be unstable or may not function as expected. We are actively working on improving it. If you encounter any issues or bugs, please open an issue or contribute via pull requests.


## Contributing

We welcome contributions to improve the app!



## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

