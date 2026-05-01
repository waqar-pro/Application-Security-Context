#!/bin/bash
POD_NAME=$1

if [ -z "$POD_NAME" ]; then
    echo "Usage: $0 <pod-name>"
    exit 1
fi

echo "=== Security Validation for Pod: $POD_NAME ==="
echo

if ! kubectl get pod $POD_NAME &>/dev/null; then
    echo "❌ Pod $POD_NAME not found"
    exit 1
fi

USER_ID=$(kubectl exec $POD_NAME -- id -u 2>/dev/null)
if [ "$USER_ID" = "0" ]; then
    echo "❌ Running as root (UID: $USER_ID)"
else
    echo "✅ Non-root user (UID: $USER_ID)"
fi

if kubectl exec $POD_NAME -- touch /test-readonly 2>/dev/null; then
    kubectl exec $POD_NAME -- rm -f /test-readonly 2>/dev/null
    echo "❌ Root filesystem is writable"
else
    echo "✅ Root filesystem is read-only"
fi

CAPS=$(kubectl exec $POD_NAME -- cat /proc/1/status 2>/dev/null | grep CapEff | awk '{print $2}')
if [ "$CAPS" = "0000000000000000" ]; then
    echo "✅ All capabilities dropped"
else
    echo "⚠️  Capabilities present: $CAPS"
fi

if kubectl get pod $POD_NAME -o yaml | grep -q "allowPrivilegeEscalation: false"; then
    echo "✅ Privilege escalation disabled"
else
    echo "❌ Privilege escalation not disabled"
fi

echo
echo "=== Done ==="

