# GitHub Copilot Instructions for Helm Charts

## Chart Version Management

**CRITICAL**: When making ANY changes to Helm charts in the `charts/` directory, you MUST bump the chart version in the `Chart.yaml` file.

### Version Bumping Rules

1. **Always bump the version** when:
   - Modifying any template files (`templates/**/*.yaml`)
   - Changing `values.yaml`
   - Updating `Chart.yaml` metadata (except the version field itself)
   - Modifying `README.md` that affects configuration
   - Adding or removing chart dependencies

2. **Version increment guidelines**:
   - **Patch version** (0.0.X): Bug fixes, minor tweaks, documentation updates that don't change functionality
   - **Minor version** (0.X.0): New features, new configuration options, backward-compatible changes
   - **Major version** (X.0.0): Breaking changes, major refactoring, incompatible API changes

3. **How to bump**:
   - Locate the `version:` field in `charts/<chart-name>/Chart.yaml`
   - Increment according to semantic versioning (semver)
   - Example: `version: 1.0.6` → `version: 1.0.7` (patch) or `version: 1.1.0` (minor)

### Workflow Checklist

When editing any chart:
- [ ] Make the requested changes to templates, values, or other chart files
- [ ] Update the `version:` field in `Chart.yaml`
- [ ] Update the `README.md` if parameter changes were made
- [ ] Verify all template references are correct

### Example

```yaml
# charts/myapp/Chart.yaml
apiVersion: v2
name: myapp
version: 1.2.3  # ← ALWAYS UPDATE THIS
```

## Additional Guidelines

- **Test changes**: Ensure templates render correctly with `helm template`
- **Document parameters**: Keep README.md in sync with values.yaml
- **Backward compatibility**: Avoid breaking changes in minor/patch versions
- **Changelog**: Consider mentioning significant changes in Chart.yaml annotations

---

**Remember**: No chart update is complete without a version bump!
