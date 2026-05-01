#!/bin/bash
echo "=== Security Analysis Report ==="
echo

for pod in basic-pod restricted-pod secure-webapp netadmin-pod no-netadmin-pod; do
    echo "--- Pod: $pod ---"
    if kubectl get pod $pod &>/dev/null; then
        echo "User ID: $(kubectl exec $pod -- id -u 2>/dev/null || echo 'N/A')"
        echo "Group ID: $(kubectl exec $pod -- id -g 2>/dev/null || echo 'N/A')"
        echo "Root filesystem writable: $(kubectl exec $pod -- touch /test-write 2>/dev/null && echo 'Yes' || echo 'No')"
        kubectl exec $pod -- rm -f /test-write 2>/dev/null
        echo "Capabilities: $(kubectl exec $pod -- cat /proc/1/status 2>/dev/null | grep CapEff || echo 'N/A')"
    else
        echo "Pod not found or not ready"
    fi
    echo
done

