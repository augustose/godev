# Build Number Versioning

This project uses a build number system to track versions between commits.

## Current Version Format

```
VERSION+build.BUILD_NUMBER
```

Example: `2.0.0+build.44`

## How It Works

1. **VERSION**: The semantic version (e.g., `2.0.0`)
2. **BUILD**: Auto-incremented number on each commit (starts at 1)

## Checking Your Version

```bash
godev version
# Output: godev version 2.0.0+build.44
```

## Incrementing Build Number

### Automatic (Recommended)

Before making a commit, run:

```bash
./increment-build.sh
```

This will:
- Increment the BUILD number in `godev`
- Show the new version
- You can then commit the changes

### Manual

Edit `godev` and update the BUILD variable:

```zsh
BUILD="45"  # Change this number
```

## Workflow

1. Make your changes
2. Run `./increment-build.sh` to increment build number
3. Commit changes (build number will be included)
4. The version command will show the new build number

## Why This Is Useful

- **Track versions**: Know exactly which build you're using
- **Debug issues**: Report specific build numbers when issues occur
- **Development tracking**: See how many iterations you've made
- **Sync verification**: Ensure you're using the latest version

---

**Note**: The build number increments independently of the semantic version. Update VERSION manually when you make major/minor/patch releases.

