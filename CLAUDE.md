# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build and Test Commands

### Building
- Build with Xcode: `xcodebuild -scheme MarkdownUI`
- Swift Package Manager: `swift build`

### Testing
- Run all tests: `make test`
- Platform-specific testing:
  - macOS: `make test-macos`
  - iOS Simulator: `make test-ios`
  - tvOS Simulator: `make test-tvos`
  - watchOS Simulator: `make test-watchos`
  - Mac Catalyst: `make test-macos-maccatalyst`

### Code Formatting
- Format code: `make format` (uses `swift format --in-place --recursive .`)

## Project Architecture

### Core Components
MarkdownUI is a SwiftUI library for rendering GitHub Flavored Markdown with a modular, extensible architecture:

**Rendering Pipeline:**
- `MarkdownParser.swift`: Converts Markdown strings to AST using cmark-gfm extensions
- `BlockNode`/`InlineNode`: AST representation of parsed Markdown content
- `Views/`: SwiftUI views that render the AST nodes to UI components
- `Theme.swift`: Theming system for customizing appearance

**Key Features:**
- **Math Support**: Added LaTeX math rendering (both inline `$...$` and block `$$...$$`)
- **GitHub Flavored Markdown**: Supports tables, task lists, strikethrough, autolinks
- **Extensible Theming**: Built-in themes (basic, gitHub, docC) with custom theme creation
- **Image Providers**: Pluggable image loading system with network and asset support
- **Platform Support**: iOS 15+, macOS 12+, tvOS 15+, watchOS 8+ (some features require newer versions)

**DSL and Content Builders:**
- `DSL/Blocks/`: Domain-specific language for building Markdown content programmatically
- `MarkdownContentBuilder`: SwiftUI-style result builder for composing Markdown

**Extensions and Customization:**
- `Extensibility/`: Plugin system for custom image providers and syntax highlighters
- Environment values for theme, image providers, and base URLs

### Dependencies
- `swift-cmark`: CommonMark parsing with GitHub Flavored Markdown extensions
- `NetworkImage`: Network image loading and caching
- `swift-snapshot-testing`: UI testing via image snapshots (test target only)

### Testing Strategy
Uses snapshot testing with platform-specific UI validation. Tests run on iOS Simulator by default, with comprehensive coverage of all Markdown features including the new math rendering capabilities.