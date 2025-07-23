# Contributing to Reductio

Thank you for your interest in contributing to Reductio! This document provides guidelines and instructions for contributing to the project.

## Code of Conduct

By participating in this project, you agree to abide by our code of conduct: be respectful, inclusive, and constructive in all interactions.

## How to Contribute

### Reporting Issues

1. **Check existing issues** to avoid duplicates
2. **Use issue templates** when available
3. **Provide details**:
   - Swift version
   - Platform (iOS/macOS/tvOS/watchOS) and version
   - Steps to reproduce
   - Expected vs actual behavior
   - Code samples if applicable

### Suggesting Features

1. **Open an issue** with the "Feature Request" label
2. **Describe the problem** the feature would solve
3. **Propose a solution** with API examples
4. **Consider alternatives** you've explored

### Pull Requests

1. **Fork the repository** and create a feature branch
2. **Follow code style**:
   - Swift API Design Guidelines
   - Use SwiftFormat (configuration included)
   - No force unwrapping
   - Add documentation comments
3. **Write tests** for new functionality
4. **Update documentation** as needed
5. **Ensure CI passes** before submitting

## Development Setup

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/Reductio.git
cd Reductio

# Add upstream remote
git remote add upstream https://github.com/fdzsergio/Reductio.git

# Create a feature branch
git checkout -b feature/your-feature-name

# Install SwiftFormat (optional but recommended)
brew install swiftformat
```

## Building and Testing

```bash
# Build the library
swift build

# Run tests
swift test

# Generate documentation
swift package generate-documentation

# Format code
swiftformat .
```

## Commit Guidelines

- Use clear, descriptive commit messages
- Reference issue numbers when applicable
- Keep commits focused and atomic
- Format: `type: description (#issue)`

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `test`: Test additions/changes
- `refactor`: Code refactoring
- `style`: Code style changes
- `chore`: Build/tooling changes

Examples:
```
feat: add support for multiple languages (#42)
fix: correct memory leak in TextRank (#13)
docs: update installation instructions
```

## Testing Guidelines

- Write tests for all new functionality
- Use Swift Testing framework (not XCTest)
- Aim for high code coverage
- Test edge cases and error conditions
- Include performance tests for critical paths

Example test:
```swift
@Test("Keywords extraction returns expected count")
func testKeywordCount() async {
    let text = "Sample text for testing keyword extraction"
    let keywords = await Reductio.keywords(from: text, count: 3)
    #expect(keywords.count == 3)
}
```

## Documentation

- Add DocC comments to all public APIs
- Include code examples in documentation
- Update README.md for significant changes
- Keep documentation concise but comprehensive

Example:
```swift
/// Extracts keywords from the provided text.
/// 
/// - Parameters:
///   - text: The source text to analyze
///   - count: Maximum number of keywords to return
/// - Returns: An array of keywords ordered by importance
/// 
/// ## Example
/// ```swift
/// let keywords = await Reductio.keywords(from: article, count: 5)
/// ```
public static func keywords(from text: String, count: Int) async -> [String]
```

## Performance Considerations

- Profile code changes for performance impact
- Avoid unnecessary allocations
- Use value types where appropriate
- Consider memory usage for large documents
- Add benchmarks for critical algorithms

## Questions?

Feel free to:
- Open an issue for questions
- Reach out to @fdzsergio on Twitter
- Email: fdz.sergio@gmail.com

Thank you for contributing to Reductio! 🙏
