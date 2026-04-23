#!/bin/bash
echo "=== Kubernetes Security Validation Tests ==="
echo
echo "1. Testing Pod Security Standards Compliance..."
kubectl get pods -n ecommerce-app -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.securityContext.runAsNonRoot}{"\t"}{.spec.containers[*].securityContext.allowPrivilegeEscalation}{"\n"}{end}' | while read pod runAsNonRoot allowPrivEsc; do
    if [[ "$runAsNonRoot" == "true" && "$allowPrivEsc" == "false" ]]; then
        echo "✓ $pod: Compliant"
    else
        echo "✗ $pod: Non-compliant"
    fi
done
echo
echo "2. Testing Network Policy Enforcement..."
FRONTEND_POD=$(kubectl get pod -l app=secure-web-frontend -n ecommerce-app -o jsonpath='{.items[0].metadata.name}')
BACKEND_POD=$(kubectl get pod -l app=secure-api-backend -n ecommerce-app -o jsonpath='{.items[0].metadata.name}')
kubectl exec $FRONTEND_POD -n ecommerce-app -- nc -zv secure-mysql-service 3306 >/dev/null 2>&1 && echo "✗ Frontend → Database: RISK!" || echo "✓ Frontend → Database: Blocked"
kubectl exec $BACKEND_POD -n ecommerce-app -- nc -zv secure-mysql-service 3306 >/dev/null 2>&1 && echo "✓ Backend → Database: Allowed" || echo "✗ Backend → Database: Blocked"
echo
echo "=== Validation Complete ==="
