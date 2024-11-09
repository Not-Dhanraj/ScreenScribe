# ScreenScribe (Alpha)

**ScreenScribe** is an innovative app that allows users to capture screenshots and extract text from them using OCR (Optical Character Recognition). Designed to streamline productivity, ScreenScribe makes it easy to quickly capture information, search for text within images, and save content for later use. 

> **Note**: ScreenScribe is currently in the **alpha stage** and may contain bugs. This is a fun project, so it does not yet follow a specific app structure or design pattern.

## Features

- [x] **Screenshot Capture**: Easily capture screenshots and store them.
- [x] **OCR Text Extraction**: Convert text in images to editable and searchable text.
- [ ] **History Management**: View and organize past screenshots and extracted text.
- [ ] **Quick Share**: Share text or images directly from the app to other apps.
- [x] **Copy to Clipboard**: Quickly copy extracted text to the clipboard for easy pasting.

## Screenshots

| ![Photo 1](https://raw.githubusercontent.com/Not-Dhanraj/ScreenScribe/refs/heads/main/showcase/Screenshot_1731144377.png) | ![Photo 2](https://raw.githubusercontent.com/Not-Dhanraj/ScreenScribe/refs/heads/main/showcase/Screenshot_1731144389.png) |
|---------------------------------------------|---------------------------------------------|
| ![Photo 3](https://raw.githubusercontent.com/Not-Dhanraj/ScreenScribe/refs/heads/main/showcase/Screenshot_1731144453.png) | ![Photo 4](https://raw.githubusercontent.com/Not-Dhanraj/ScreenScribe/refs/heads/main/showcase/Screenshot_1731144437.png) |

## Videos

https://github.com/user-attachments/assets/935c4472-aa43-482c-b3bb-f6e372ee85ee



## Installation

1. **Clone the Repository**
   ```bash
   git clone https://github.com/Not-Dhanraj/ScreenScribe.git
   cd ScreenScribe
   ```

2. **Install Dependencies**
   Make sure you have Flutter installed, then install dependencies:
   ```bash
   flutter pub get
   ```

3. **Run the App**
   ```bash
   flutter run
   ```

## Usage

1. **Capture Screenshot**: Take a screenshot by tapping on the overlay icon.
2. **Extract Text**: ScreenScribe will automatically analyze the image and extract any readable text using google ml kit.
3. **Manage Text**: Edit, copy, or search extracted text from your screenshots.

## Technical Overview

- **Built with Flutter**: A cross-platform framework that ensures the app runs smoothly on both iOS and Android devices.
- **Path Provider**: Used to access directories and locate screenshots.
- **Google ML Kit**: Utilized for robust and accurate OCR text extraction from images, enabling high-quality text recognition directly on-device.


## Current Status

**Alpha Version**: ScreenScribe is still in its early development stages. As a fun project, it does not follow a structured design or architecture and may have significant bugs or unimplemented features. Contributions are welcome to help improve stability, design, and functionality.

## Contributing

We welcome contributions to **ScreenScribe**! If you’d like to add features, fix bugs, or improve the codebase:

1. Fork the repository.
2. Create a new branch:
   ```bash
   git checkout -b feature-name
   ```
3. Commit your changes:
   ```bash
   git commit -m "Add new feature"
   ```
4. Push to the branch:
   ```bash
   git push origin feature-name
   ```
5. Open a Pull Request.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

<!-- ## Contact

For any questions or suggestions, please reach out:

- **Email**: yourname@email.com
- **GitHub**: [username](https://github.com/username) -->
