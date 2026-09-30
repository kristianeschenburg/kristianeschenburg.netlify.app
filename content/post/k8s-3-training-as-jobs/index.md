---
# Documentation: https://sourcethemes.com/academic/docs/managing-content/

title: "Kubernetes for ML Engineering, Part 3: Training a Model as a Kubernetes Job"
subtitle: ""
summary: "Why training belongs in a Job and not a Deployment, how GPU allocation is expressed, and where a single Job stops being enough."
authors: []
tags: [Kubernetes, PyTorch, GPU, batch, Jobs, distributed training]
categories: [ml platform, software engineering]
date:   2026-09-22T09:00:00-07:00
featured: false
draft: true

# Featured image
# To use, add an image named `featured.jpg/png` to your page's folder.
# Focal points: Smart, Center, TopLeft, Top, TopRight, Left, Right, BottomLeft, Bottom, BottomRight.
image:
  caption: ""
  focal_point: ""
  preview_only: false

# Projects (optional).
#   Associate this post with one or more of your projects.
#   Simply enter your project's folder or file name without extension.
#   E.g. `projects = ["internal-project"]` references `content/project/deep-learning/index.md`.
#   Otherwise, set `projects = []`.
projects: []
---

> **Working notes — delete everything above the horizontal rule before publishing.**

### Interview talking points this earns

- "I've run training as a K8s Job with retry logic and hard timeouts, init containers for data staging, artifacts persisted to object storage."
- "I know how GPU allocation is expressed (nvidia.com/gpu), which nodes get GPUs (labels + taints), and why the NVIDIA device plugin has to be installed for any of it to work."
- "For distributed training I'd reach for PyTorchJob or KubeRay's TorchTrainer — I haven't operated them, but I understand the problems they solve: gang scheduling, elastic membership, pod-per-rank topology."

### Artifacts to keep

- [ ] Public repo: k8s-ml-training — README with blog link and run instructions
- [ ] Three things I'd do differently at production scale

### Done criteria

- [ ] kubectl apply -f train-job.yaml runs training to completion
- [ ] Artifacts land in the PVC (or object store) and survive Job cleanup
- [ ] kubectl logs -f job/<name> streams training progress
- [ ] I've deliberately failed the Job (bad flag, missing data) and watched the retries
- [ ] I can explain how parallelism and completions interact
- [ ] I can explain why gang scheduling is the thing a plain Job cannot give me  <-- sets up Part 4

### What to read

- [ ] Kubernetes Concepts: Jobs and CronJobs
- [ ] restartPolicy: OnFailure vs Never — when each is right
- [ ] Kubeflow: PyTorchJob overview and spec
- [ ] KubeRay: TorchTrainer concepts
- [ ] PyTorch distributed training documentation (DDP section)
- [ ] NCCL primer: collective operations and failure modes (hangs, timeouts, NCCL_TIMEOUT)

### What to build

- [ ] Create a Kubernetes Job that runs model training to completion
- [ ] Configure backoffLimit (retry budget) and activeDeadlineSeconds (hard timeout)
- [ ] Implement init container for data staging into a shared volume
- [ ] Set up PVC storage for artifacts (or note why production uses S3/object storage)
- [ ] Add resource requests including nvidia.com/gpu (even if commented out for kind)
- [ ] Create ServiceAccount with minimal permissions for artifact writing
- [ ] Configure ttlSecondsAfterFinished for automatic cleanup
- [ ] Test Job retry behavior and verify artifacts persist after Job cleanup

### GPU access for Part 3

For this part, **CPU-only on kind is fine** — learning the Job manifest patterns doesn't require a GPU. The `nvidia.com/gpu: 1` in the spec is enough to show you understand the syntax. If you want to actually run with a GPU later:
- Optional: rent a GPU box (Lambda Labs, RunPod, Vast.ai) for a few hours (~$0.50-2/hr depending on GPU tier)
- Install k3s or kubeadm on the rented box
- Point kubectl at it from your laptop with a kubeconfig
- This buys you the "I've actually allocated a real GPU" story without long-term commitment

Save the real GPU workload demo for Part 5 (capstone) where it matters more for the narrative.

### Sections to write

- Why a Job and not a Deployment (retry semantics, completion detection, cleanup)
- The manifest field-by-field (restartPolicy, backoffLimit, activeDeadlineSeconds, parallelism, completions, ttlSecondsAfterFinished)
- GPU allocation (extended resources, device plugin, taints/tolerations)
- Data staging and artifact output (init containers, PVC vs object storage)
- Making the Job resumable (checkpointing, restart behavior)
- Where a single Job stops working (gang scheduling, PyTorchJob, KubeRay as the next layer)

---

## Why a Job and not a Deployment

*Deployments assume the process should always be running; training assumes it should finish. Retry semantics, completion detection, and cleanup all differ.*

## The manifest, field by field

*`restartPolicy`, `backoffLimit`, `activeDeadlineSeconds`, `parallelism`, `completions`, `ttlSecondsAfterFinished` — what each one actually protects you from.*

```yaml
# TODO: paste the training Job
```

## GPU allocation

*How it's expressed (`nvidia.com/gpu` as an extended resource), how it works (device plugin), what breaks: driver/CUDA mismatch across nodes, no fractional GPUs, taints and tolerations to keep non-GPU work off expensive nodes.*

## Staging data and getting artifacts out

*Init container for data staging. PVC vs. object storage: the tradeoff, and why storage-to-GPU bandwidth is the number that matters at foundation-model scale.*

## Making the Job resumable

*Checkpoint cadence, where checkpoints live, what a restart actually replays. Sharded and async checkpointing when the checkpoint is hundreds of GB.*

## Where a single Job stops working

*Gang scheduling: N pods that are useless unless all N are running. PyTorchJob (Kubeflow Trainer) and KubeRay as the next layer — what they add on top of a plain Job, and what they cost operationally. This is the on-ramp to Part 4.*

## Failure modes worth naming

*OOM from uneven memory across ranks, stragglers, silent NaN divergence on one rank, NCCL hangs and timeouts.*
