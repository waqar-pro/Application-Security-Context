# Kubernetes SecurityContext Best Practices

## Essential Security Settings

1. Always run as non-root
   - Set `runAsNonRoot: true`
   - Specify explicit `runAsUser` and `runAsGroup`

2. Use read-only root filesystem
   - Set `readOnlyRootFilesystem: true`
   - Mount writable volumes for application data

3. Drop all capabilities by default
   - Use `capabilities.drop: [ALL]`
   - Only add specific capabilities when needed

4. Disable privilege escalation
   - Set `allowPrivilegeEscalation: false`

5. Use security profiles
   - Enable seccomp: `seccompProfile.type: RuntimeDefault`
   - Consider AppArmor or SELinux profiles

## Common Pitfalls to Avoid

- Running containers as root (UID 0)
- Allowing writable root filesystem
- Granting unnecessary Linux capabilities
- Not setting explicit user/group IDs
- Ignoring Pod Security Standards

## Validation Checklist

- [ ] Non-root user configured
- [ ] Read-only root filesystem enabled
- [ ] All capabilities dropped (unless specifically needed)
- [ ] Privilege escalation disabled
- [ ] Security profiles configured
- [ ] Writable volumes mounted only where needed

## Troubleshooting Common Issues

### Issue 1: Pod Fails - "container has runAsNonRoot and image will run as root"
**Solution:** Container image non-root support kare,
ya custom image banao proper user config ke saath.

### Issue 2: "Permission denied" on read-only filesystem
**Solution:** emptyDir volumes mount karo un directories
ke liye jo write access chahti hain (/tmp, /var/cache, /var/run).

### Issue 3: Network operations fail even with NET_ADMIN
**Solution:** Capability container level pe add karo,
Pod level pe nahi. User permissions bhi check karo.

### Issue 4: SecurityContext settings ignored
**Solution:** Settings sahi level pe apply karo
(Pod vs Container) aur conflicting policies check karo.

