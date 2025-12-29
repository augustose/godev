# Contributing to godev

Thank you for your interest in contributing to godev! This document provides guidelines and instructions for contributing.

## Code of Conduct

- Be respectful and inclusive
- Welcome newcomers and help them learn
- Focus on constructive feedback
- Be patient with questions

## How to Contribute

### Reporting Bugs

1. Check if the bug has already been reported in [Issues](https://github.com/tu-usuario/godev/issues)
2. If not, create a new issue using the bug report template
3. Include:
   - Clear description of the bug
   - Steps to reproduce
   - Expected vs actual behavior
   - Environment (OS, ZSH version, etc.)

### Suggesting Features

1. Check if the feature has already been suggested
2. Create a feature request issue
3. Explain:
   - The problem it solves
   - Proposed solution
   - Use cases

### Submitting Code

1. **Fork the repository**
2. **Create a branch** from `main`:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes**
   - Follow the code style
   - Add tests if applicable
   - Update documentation
4. **Test your changes**
   - Run existing tests
   - Test in readonly mode
   - Verify no breaking changes
5. **Commit your changes**:
   ```bash
   git commit -m "feat: Add your feature description"
   ```
6. **Push and create a Pull Request**

## Development Setup

```bash
# Clone your fork
git clone https://github.com/your-username/godev.git
cd godev

# Make script executable
chmod +x godev

# Test
./godev help
./godev status
```

## Code Style

- Use ZSH-specific features (this is a ZSH-only script)
- Follow existing code patterns
- Add comments for complex logic
- Keep functions focused and small
- Use meaningful variable names

## Testing

- Test in readonly mode (READONLY_MODE=true)
- Verify no modifications to development folders
- Test edge cases
- Test with different directory structures

## Commit Messages

Follow conventional commits:
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation
- `test:` - Tests
- `refactor:` - Code refactoring
- `style:` - Formatting

Example:
```
feat: Add ai-status command for AI tool detection
```

## Pull Request Process

1. Ensure all tests pass
2. Update documentation if needed
3. Add description of changes
4. Reference related issues
5. Wait for review and feedback

## Questions?

Feel free to open an issue for questions or discussions!

Thank you for contributing! 🎉

