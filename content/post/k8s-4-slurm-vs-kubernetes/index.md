---
# Documentation: https://sourcethemes.com/academic/docs/managing-content/

title: "Kubernetes for ML Engineering, Part 4: SLURM vs Kubernetes, from the Batch Scheduler Side"
subtitle: ""
summary: "I ran training under a batch scheduler for years before I wrote a Deployment manifest. What Kubernetes gets right and wrong about that workload."
authors: []
tags: [Kubernetes, SLURM, HPC, qsub, Kueue, Volcano, KubeRay, scheduling]
categories: [ml platform, software engineering]
date:   2026-09-23T09:00:00-07:00
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

### Interview talking point

- "I ran training under a batch scheduler for years before I wrote a Deployment manifest, so I know what K8s is competing with, not just what it offers."

### What this post is

- Reportage from HPC batch experience (SGE/qsub, PyTorch DDP on in-house HPC) contrasted with self-directed Kubernetes learning — the highest-leverage post in the series and the only one with no project dependency.
- Written with honesty: I have HPC batch experience but not production K8s-at-scale experience.
- A defended position, not "it depends" — what I'd pick green-field and why.

### What to read

- [ ] SLURM quick start and documentation (gang scheduling, backfill, fair-share)
- [ ] Kueue (Kubernetes queueing and quota layer)
- [ ] Volcano (batch scheduler replacement for Kubernetes)
- [ ] KubeRay (distributed training framework on Kubernetes)
- [ ] Articles by people who operated each system at scale

### GPU note for Part 4

Since this post is analytical, GPU access isn't critical. However, if you want to **test Kueue's GPU scheduling** to make the comparison concrete (optional, strong signal): use the same GPU rental approach as Part 5. Run a batch of Jobs against Kueue's quota system to observe gang scheduling and backfill behavior on actual GPUs. This would strengthen the "I tested this, not just read about it" credibility.

### What to write

- [ ] Where I'm writing from (HPC batch background, self-directed K8s experience, explicit about what I haven't operated)
- [ ] What the batch scheduler got right (gang scheduling as default, queue semantics, fair-share, backfill, qsub/qstat mental model)
- [ ] What it got wrong (module load environment management, no isolation, nowhere for long-running services)
- [ ] What Kubernetes gets right (unified control plane, isolation primitives, operational leverage)
- [ ] What Kubernetes gets wrong for batch workloads (scheduler built for services, no native gang scheduling, queueing bolted on)
- [ ] The convergence assessed honestly (Kueue, Volcano, KubeRay — what's still missing, not just claims)
- [ ] The pragmatic answer at scale (many orgs run both with unified job API)
- [ ] Green-field recommendation with defense

---

## Where I'm writing from

*A PhD spent submitting jobs to an SGE cluster with `qsub`, then PyTorch DDP on in-house HPC. Batch schedulers were how I ran every model I ever trained, for years, before I ever wrote a Deployment manifest. State plainly what I have and haven't operated — HPC batch, yes; K8s at production scale, not yet — and let the rest of the post earn its authority from the first half of that.*

## What the batch scheduler actually got right

*The parts I didn't appreciate until I went looking for them in Kubernetes and couldn't find them. Gang scheduling as the default rather than an add-on. A queue you can actually reason about. Fair-share and backfill that had two decades of tuning behind them. `squeue`/`qstat` as a complete mental model of the cluster in one screen.*

## What it got wrong

*Be equally specific and don't romanticize it. Environment management by module load and prayer. No isolation worth the name. Everything that wasn't a training job — serving, dashboards, data pipelines, anything long-running — had nowhere to live. The cluster was a place you sent jobs, not a place you ran a platform.*

## What Kubernetes gets right

*One control plane for training, inference, agents, feature pipelines, and monitoring. Isolation and identity as first-class primitives (Parts 2 and 3 of this series). The operational leverage of not running two systems.*

## What Kubernetes gets wrong about this workload

*The scheduler was built for services that should always be running, not for jobs that should finish — the distinction Part 3 opened with. No native gang scheduling. Queueing bolted on rather than built in. Per-pod scheduling decisions for a workload where the unit of work is N pods or nothing.*

## The convergence, assessed honestly

*Kueue, Volcano, KubeRay: each imports HPC scheduling ideas into K8s. How far does each actually get, and what does each cost operationally? This is where a lot of writing gets hand-wavy — be concrete about what's still missing.*

## The pragmatic answer at scale

*Many mature orgs run both: SLURM for the largest runs, K8s for everything else, with a unified job submission API on top so researchers never have to know which one their job landed on. What that API has to promise, and why the abstraction leaks.*

## What I'd pick green-field

*Commit to a recommendation and defend it. This is the paragraph people will quote back to me.*
