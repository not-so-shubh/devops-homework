# Kubernetes Volume Notes and Examples

| Resource | Lifetime and purpose | Typical use |
|---|---|---|
| `emptyDir` | Created with a Pod and deleted with that Pod | Scratch space, caches, sharing files between containers |
| `hostPath` | Mounts a path from one node; node-specific and security-sensitive | Single-node labs or node agents, not portable application data |
| PersistentVolume (PV) | Cluster storage resource with its own lifecycle and reclaim policy | Administrator-provisioned storage |
| PersistentVolumeClaim (PVC) | A workload's request for capacity and access mode | Stable application storage independent of Pod identity |
| StorageClass | Describes a storage tier and provisioner | Standard, SSD, encrypted or topology-aware storage classes |
| Dynamic provisioning | A PVC triggers automatic PV creation through a StorageClass/CSI driver | Normal cloud and managed-cluster workflow |

## Practical observations

- The two containers in `emptydir.yaml` see the same files because the volume is mounted into both containers.
- `hostpath.yaml` is constrained to a single node. Data can disappear from the workload's point of view when it is scheduled elsewhere.
- `pv-pvc.yaml` demonstrates static binding. The PV is cluster-scoped; the PVC and Pod are namespaced.
- `storageclass-pvc.yaml` uses Minikube's default StorageClass, so the provisioner creates a matching PV after the PVC is submitted.
- `ReadWriteOnce` permits read/write mounting from one node, not necessarily only one Pod. Access mode support depends on the storage driver.
- A reclaim policy of `Delete` removes dynamically provisioned backing storage after claim deletion; `Retain` requires explicit administrator cleanup.

Inspect the relationships with:

```bash
kubectl get storageclass
kubectl get pv
kubectl get pvc -n session13
kubectl describe pvc dynamic-data -n session13
kubectl exec -n session13 emptydir-demo -c reader -- cat /shared/message.txt
```
