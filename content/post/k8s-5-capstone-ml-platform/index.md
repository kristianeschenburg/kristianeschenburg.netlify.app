---
# Documentation: https://sourcethemes.com/academic/docs/managing-content/

title: "Kubernetes for ML Engineering, Part 5: A Minimal Multi-Tenant ML Platform"
subtitle: ""
summary: "Two research teams, one cluster: RBAC boundaries, a shared training queue, an autoscaled serving path, and what's still missing for production."
authors: []
tags: [Kubernetes, ML platform, Kueue, KEDA, Terraform, multi-tenancy, architecture]
categories: [ml platform, software engineering]
date:   2026-09-24T09:00:00-07:00
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

- "I've deployed a model behind HPA and load-tested the scaling behavior. Here's what I learned about scale-up latency vs stabilization windows."
- "CPU-util scaling is usually the wrong signal for inference — the GPU saturates long before the CPU does. You want queue depth or in-flight requests, which is what KEDA is for."
- "I built a minimal multi-tenant platform: two teams, isolated by namespace and RBAC, sharing a queue and a serving path, with one end-to-end path from job submission to served model."

### Artifacts to keep

- [ ] Public repos: k8s-ml-serving and k8s-ml-platform
- [ ] Architecture diagram for the capstone
- [ ] Squash the wip commits before publishing — 8 clean commits read far better than 40
- [ ] Three things I'd do differently at production scale

### Done criteria

- [ ] Single inference request returns correctly
- [ ] Load test drives replicas from 2 to N, and I watched them come back down
- [ ] I can articulate the latency-vs-throughput tradeoff in MY setup: batch size, concurrent request cap, warmup cost
- [ ] The end-to-end demo runs from a clean cluster with a documented command sequence
- [ ] tenant-a cannot read, exec into, or submit against tenant-b — demonstrated, not asserted
- [ ] I can name what's missing for production without hand-waving

### What to read: serving

- [ ] Kubernetes Concepts: Horizontal Pod Autoscaling and Vertical Pod Autoscaling
- [ ] KEDA: overview and scaler examples
- [ ] PodDisruptionBudget and graceful shutdown patterns
- [ ] TorchServe or Triton (model serving stack overview)

### What to read: capstone

- [ ] Kueue or Volcano (batch scheduling and quota system)
- [ ] Prometheus and Grafana basics
- [ ] OpenTelemetry and distributed tracing concepts
- [ ] Multi-cluster patterns (Cluster API, KubeFed) — conceptually only

### What to build: serving

- [ ] Wrap the Part 3 trained model in a serving stack (TorchServe recommended for simplicity and interview signal)
- [ ] Deployment with 3 replicas, Service, Ingress
- [ ] Install metrics-server and apply TLS patch for kind
- [ ] HPA on CPU util (autoscaling/v2) with minReplicas 2, maxReplicas 10, target 70%
- [ ] Implement proper readiness (model loaded) and liveness (not deadlocked) probes
- [ ] Load test with concurrent requests and record scale-up lag, overshoot, stabilization window behavior

### GPU access for Part 5 (capstone)

This is where a real GPU matters for the story. For the capstone, **consider renting a GPU box for one weekend** (~$10-20 total):
- **Providers**: Lambda Labs, RunPod, Vast.ai, or a cloud provider (AWS g4dn, GCP L4, Azure NC)
- **What to rent**: single A100 or H100 for ~$1-2/hr, or cheaper L4/T4 for ~$0.30-0.50/hr (sufficient for model serving demo)
- **Setup**: install k3s on the rented instance in ~5 minutes
- **From your laptop**: export the kubeconfig and point kubectl at the remote cluster — your local manifests apply unchanged
- **Payoff**: "I've run inference on an actual GPU, scaled from 2 to N replicas under load, and watched the autoscaling behavior" is a complete and credible story

This gives you a real GPU allocation story for interviews without long-term infrastructure cost. The capstone narrative is much stronger if you can say "here's the load test output on actual GPUs" rather than "here's what it would look like."

### What to build: capstone

- [ ] Two tenant namespaces (tenant-a, tenant-b) with isolated RBAC boundaries (from Part 2)
- [ ] Shared training queue (Kueue) with per-tenant quota admission
- [ ] Shared inference gateway fronting both tenants' models
- [ ] Tenant-scoped model registry (prefixed object-store paths)
- [ ] End-to-end demo: submit training job → artifact lands → serving picks it up
- [ ] Test tenant isolation: tenant-a cannot read/exec/submit against tenant-b

### Optional extensions

- [ ] KEDA scaling on custom metric (queue depth from Redis)
- [ ] Canary deployment (90/10 split via Service selector)
- [ ] Prometheus + Grafana dashboards for inference latency
- [ ] Rate limiter at Ingress layer

### The closing statement

"I've used ECS/Fargate in production for years. To close the K8s gap I built a series of projects — a two-service app for the service and networking primitives, a training Job for batch workloads and GPU allocation, an autoscaled inference deployment for HPA and load behavior, and a small multi-tenant platform tying them together. I haven't operated a production K8s cluster at scale yet, but I can hit the ground running and grow into it fast."

---

## The scenario

*Two research teams sharing one cluster, each needing to train and serve models without being able to step on the other.*

## The architecture

*TODO: diagram. Namespaces, RBAC boundaries, the shared queue, the shared serving path, a tenant-scoped model registry.*

## Walking one job through the system

*Submit -> admitted by quota -> scheduled -> trains -> writes an artifact -> serving picks it up. Where it can fail at each hop.*

## The serving path

*Wrap a trained model, deploy behind a Service, expose through the Ingress from Part 2.*

*HPA scales on CPU by default, which is usually the wrong signal for inference — the GPU saturates long before the CPU does. KEDA lets you scale on the thing that actually correlates with tail latency: queue depth, in-flight requests, request rate.*

*Cold starts: model load time dominates pod startup, so min replicas stays above zero. Image size and `imagePullPolicy`, warm pools, readiness probes that don't lie about warmup. PodDisruptionBudgets and graceful shutdown so a node drain doesn't drop requests.*

*TODO: load test numbers and a graph — scale-up lag, overshoot, stabilization window.*

## Every primitive in the series, doing a job here

*Bring it full circle: Services and probes from Part 1, Ingress/NetworkPolicy/RBAC from Part 2, Jobs and GPU scheduling from Part 3, the queueing layer from Part 4.*

## What this is missing for production

*Observability and tracing across the whole path, cost attribution per team, quota enforcement that holds under pressure, incident response paths, upgrade strategy. Naming these is the point.*

## What building this changed in my thinking

*The synthesis paragraph. What I believe now about ML platforms that I didn't believe five posts ago.*
