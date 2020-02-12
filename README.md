# envinit-operator

This operator will watch namespace add events. If the namespace contains the annotation ```envinit.joyrex2001.com/type``` it will run the ```run.sh``` shell script in the environment folder for that type. In this example it will do an additional kustomize run.

To install this operator;
```bash
kubectl create namespace operator-envinit
kustomize build kustomize | kubectl apply -f -
```

## Create a new namespace

To trigger the operator to provision the environment with the annotation as below. This will trigger the ```environment/dev/run.sh``` script to be executed.

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: example-environment
  annotations:
    "envinit.joyrex2001.com/type": "dev"
```

## See also

* https://github.com/flant/shell-operator
* https://www.hcs-company.com/blog/operator-automatiseren-namespace-openshift
