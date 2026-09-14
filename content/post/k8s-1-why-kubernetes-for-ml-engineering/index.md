---
# Documentation: https://sourcethemes.com/academic/docs/managing-content/

title: "Kubernetes for ML Engineering, Part 1: Why, and Two Services Talking"
subtitle: ""
summary: "Why I'm learning Kubernetes for ML engineering, and getting two services talking on a local cluster."
authors: []
tags: [Kubernetes, FastAPI, Docker, service discovery, ML platform]
categories: [ml platform, software engineering]
date:   2026-09-13T09:00:00-07:00
featured: false
draft: false

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

## Why Kubernetes, and why now

I come from an ML-heavy academic research background, where I applied machine learning methods to medical imaging and brain network analysis. My work focused primarily on segmentation and computer vision, and I developed graph neural network approaches to better understand brain architecture. In my current role at Just-Evotec Biologics, I've built and deployed protein language models for antibody optimization and antibody property prediction. In all of these cases, I've had access to on-prem GPU compute and used schedulers like Slurm and Sun Grid Engine for training and inference.

My more recent work has moved away from ML development and toward cluster management, specifically deploying and scaling many applications on our cluster. At Just, we've used AWS ECS almost exclusively for this.

I wanted to learn Kubernetes, specifically for machine learning training and inference. ECS has worked well for us, but a lot of the open-source tooling for ML platforms is built for Kubernetes. I also wanted to see how Kubernetes compares to the different HPC schedulers I've used for training. This series covers my exploration of Kubernetes (K8s) for machine learning engineering. It starts with foundational topics like Pods and Services, moves to intermediate topics like role-based access control (RBAC) and networking, and ends with topics specific to ML platforms like horizontal pod autoscaling (HPA), multi-tenant namespaces, and job queuing.

## What's coming

I'll post my progress as a series of five blog posts:

1. Part 1: Why, and Two Services Talking
2. Part 2: Networking and RBAC
3. Part 3: Model Training as Jobs
4. Part 4: Slurm vs. Kubernetes
5. Part 5: Capstone ML Platform

## Part 1: Two services need to find each other

One of the most basic capabilities I've had to enable for our platform is letting two services talk to each other. In a monorepo, we'd define separate modules and import one from another. But we often want to reuse one service across many applications, and in that case it makes sense to extract the reusable code into its own deployed application. That leaves the question: how do multiple deployed services communicate with each other?

You can find the full repo for my code [here](https://github.com/kristianeschenburg/k8s-for-mle-part-1).

## The naive approach

At the most basic level, we can deploy two services to the same or different EC2 instances (if using AWS) and allow traffic between the IP addresses of those instances. This approach is easy. We set up each instance, define the necessary subnets and security groups, and voila, the instances can talk to each other.

But it's not a robust way to deploy things. We have to hardcode IP addresses and, often, environment variables, and things break as soon as an instance is replaced, whether during a redeploy or when scaling up.

In K8s, the equivalent easy approach would *also* hardcode values, like node IPs or Pod IPs stored in environment variables. The first time a Pod is replaced, the applications would stop being able to communicate. Kubernetes doesn't move a Pod to a new node. It deletes the Pod and creates a new one, which usually gets a new IP address. Hardcoding is *easy*, but it is not robust.

## The Kubernetes way

Instead, we'll implement a more robust system for inter-service communication. I've set up two applications [here](https://github.com/kristianeschenburg/k8s-for-mle-part-1/tree/main/src): a very simple Python Dash frontend and a FastAPI backend. The backend loads a small CSV file containing the names and ages of individuals, and has an endpoint that returns the age of a requested person. The frontend accepts a name and displays that person's age, if they are in the table.  External users don't need to know about the backend, they just need to interact with the frontend.

We'll create two Deployments, a ConfigMap, and two Services. The backend and frontend each run in their own Pods, and the frontend reaches the backend through the backend Service's name, `part-1-backend`, rather than a hardcoded IP address.

### Deployment

We'll create two Deployments. One runs the backend container, with the label selector `app: part-1-backend`. The other runs the frontend, with the label selector `app: part-1-frontend`. Since the images are built locally, each one has to be loaded into `kind` with `kind load docker-image ${image_name}:${tag} --name ${cluster_name}`, and each container sets `imagePullPolicy: Never` so Kubernetes doesn't try to pull the image from a registry.

For each container, we specify a liveness probe at `/healthz` and a readiness probe at `/ready`, along with some environment variables pulled from the ConfigMap (see below). The backend uses `DATA_FILE` to choose which CSV file to load, and `SLEEP_DURATION` to simulate a slow startup. The first call to `/ready` blocks for `SLEEP_DURATION` seconds, so the backend isn't marked ready until that call finishes.

```yaml
# deployment.yaml

# deployment for the backend
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: part-1-backend
  name: part-1-backend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: part-1-backend
  strategy: {}
  template:
    metadata:
      labels:
        app: part-1-backend
    spec:
      containers:
      - image: part-1-backend:latest
        ports:
          - containerPort: 8000
        name: backend
        resources: {}
        imagePullPolicy: Never
        livenessProbe:
          httpGet:
            path: /healthz
            port: 8000
          initialDelaySeconds: 5  # Time to wait before first check
          periodSeconds: 10       # How often to check
          timeoutSeconds: 2       # Timeout for response
          failureThreshold: 3     # Number of failures before restarting
        readinessProbe:
          httpGet:
            path: /ready
            port: 8000
          initialDelaySeconds: 5  # Time to wait before first check
          periodSeconds: 5        # How often to check
          timeoutSeconds: 2       # Timeout for response
          failureThreshold: 3     # Number of failures before marking the container not ready
        env:
        - name: DATA_FILE
          valueFrom:
            configMapKeyRef:
              name: part-1
              key: data_file
        - name: SLEEP_DURATION
          valueFrom:
            configMapKeyRef:
              name: part-1
              key: sleep_duration
status: {}

---
# deployment for the frontend
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: part-1-frontend
  name: part-1-frontend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: part-1-frontend
  strategy: {}
  template:
    metadata:
      labels:
        app: part-1-frontend
    spec:
      containers:
      - image: part-1-frontend:latest
        ports:
          - containerPort: 8050
        name: frontend
        resources: {}
        imagePullPolicy: Never
        livenessProbe:
          httpGet:
            path: /healthz
            port: 8050
          initialDelaySeconds: 5  # Time to wait before first check
          periodSeconds: 10       # How often to check
          timeoutSeconds: 2       # Timeout for response
          failureThreshold: 3     # Number of failures before restarting
        readinessProbe:
          httpGet:
            path: /ready
            port: 8050
          initialDelaySeconds: 5  # Time to wait before first check
          periodSeconds: 5        # How often to check
          timeoutSeconds: 2       # Timeout for response
          failureThreshold: 3     # Number of failures before marking the container not ready
        env:
        - name: BACKEND_URL
          valueFrom:
            configMapKeyRef:
              name: part-1
              key: backend_url
status: {}
```

### Services

We create two Services, one for each application. By default (if no type is specified), a Service is of type ClusterIP, which means it can be reached from inside the cluster but not from outside it. We only want external users to be able to access the frontend application. For all intents and purposes, they don't even need to know that the backend exists. To do this, we make the frontend a NodePort Service, which also opens a port on every node in the cluster. In the manifest, `port` is the port the Service listens on inside the cluster, and `targetPort` is the container port that traffic is forwarded to.

```yaml
# services.yaml
apiVersion: v1
kind: Service
metadata:
  name: part-1-backend
spec:
  selector:
    app: part-1-backend
  ports:
  - port: 8000
    targetPort: 8000

---
apiVersion: v1
kind: Service
metadata:
  name: part-1-frontend
spec:
  type: NodePort
  selector:
    app: part-1-frontend
  ports:
  - port: 8050
    targetPort: 8050
```

### ConfigMap

As I mentioned above, a naive approach would be to hardcode environment variables into the image. Instead, we can define them in a ConfigMap and redeploy the Pods whenever we want to change them. Environment variables from a ConfigMap are set when the container starts, so after editing the ConfigMap we restart the Deployment that uses the changed value (for example, `kubectl rollout restart deployment part-1-backend` after changing `data_file`). This ConfigMap defines `backend_url` (used by the frontend application), `data_file`, which points to the desired CSV file of names and ages, and `sleep_duration`, which sets how long a backend container takes to become ready.

```yaml
# config-map.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: part-1
data:
  # property-like keys; each key maps to a simple value
  backend_url: "http://part-1-backend:8000"
  data_file: "special_names.csv"
  sleep_duration: "10"
```

We apply the resources in this order:

```bash
kubectl apply -f ./manifests/config-map.yaml
kubectl apply -f ./manifests/deployment.yaml
kubectl apply -f ./manifests/services.yaml
```

Are we ready? Not yet. On macOS, `kind` runs its nodes as Docker containers inside Docker Desktop's VM, so the NodePort isn't reachable from the host right off the bat. So instead we port-forward to the frontend Service:

```bash
kubectl port-forward service/part-1-frontend 8051:8050
```

Port-forwarding works with any K8s Service type and connects to a single Pod behind the Service, so it skips the load balancing (if implemented). That's fine for checking the app locally, but it isn't how external traffic would reach the frontend in a real cluster.  I'll get into load balancing in the next post.

We've set the base path of the Dash application to `/frontend/`, so once the port-forward is running we can access the frontend at http://127.0.0.1:8051/frontend/.

## Bridging the gap between ECS and K8s

Coming from ECS, my instinct was to try to map each Kubernetes object onto something I already knew well.  Most Kubernetes objects / resources have a rough ECS counterpart, but the boundaries between them are drawn in different places, and there wasn't always a direct analog for me to connect the dots with.  What helped me bridge the gap the most was just starting to play around with KinD and K8s locally, rather than viewing ECS as a template (I think that may have been more confusing actually).

| ECS | Kubernetes | Notes |
|---|---|---|
| Task Definition | Pod template (`spec.template` in a Deployment) | ECS Task Definitions are numbered revisions. K8s tracks revisions through ReplicaSets, so we can rollback to a previous revision with `kubectl rollout undo`. |
| Task | Pod | In `awsvpc` mode, all the containers in a task also share a network namespace, so the `localhost` path from my first attempt (see Gotchas below) also works in ECS. |
| Service | Deployment + Service | An ECS Service keeps N tasks running and registers them with a load balancer. K8s splits this concept into two resources. |
| Service Connect or Cloud Map | Cluster DNS | Service discovery in ECS must be specified, whereas every K8s Service gets a DNS name by default. |
| Application Load Balancer | Ingress | A `type: LoadBalancer` Service is closer to a Network Load Balancer. |
| Task role | ServiceAccount | The ECS Execution Role pulls images and fetches secrets, and maps to a K8s node's IAM role and image pull secrets. |
| Environment variables and secrets in the Task Definition | ConfigMap and Secret | Changing a ConfigMap doesn't restart anything, you have to actually run the `rollout`, just like with changing environment variables in a Task Definition.|
| Container and load balancer health checks | Liveness and readiness probes | Both are defined on the Task / Pod OR the Target Group (EC2). |
| Task CPU and memory | Container requests and limits | Required on Fargate, optional in K8s. |

Each platform's definition of "Service" was a bit confusing at first. An ECS Service keeps a desired number of tasks running, handles deploys, and attaches tasks to target groups. A K8s Service is just a name and IP in front of the Pods that match its label selector while the actual controlling of the Pods is the Deployment's job. Kubernetes also explicitly refers to objects a "Controllers" -- from that perspective it makes a lot more sense e.g. "Your job is to maintain a certain state, or to watch for certain things...".

## Speedbumps

I ran into one gotcha along the way:

1. **Single Deployment vs. separate Deployments for the two Services**.  My initial approach was to put both Services in a single Deployment, where both the frontend and backend containers were in each Pod. Since containers in a Pod share a network namespace, the frontend just referred to the backend using `localhost:8000`. But this nixed the independence of each Service, and meant the two Services could not scale independently. Splitting them into separate Deployments, each with its own label, meant the backend Service only selected backend Pods. The frontend now reaches the backend through that Service's name, and Kubernetes load-balances requests across any ready backend Pod, not just the backend container in the same Pod.

## What this looks like at scale

This setup works on a laptop, but there are a few things I'd do differently in a production cluster.

1. **Data wouldn't live in the container image.** Right now the backend's CSV files are copied into the image, so changing the data means rebuilding it. In production, the data would live in S3 or in a database like RDS. For S3 access, we'd give the backend's ServiceAccount an IAM role rather than storing long-lived AWS keys in a Kubernetes Secret.

2. **Service-to-service traffic would be explicitly allowed, not open by default.** a.k.a principle of least priviledge a.k.a. need-to-know. I didn't implement any authentication or network policies. By default, every Pod in a K8s cluster can reach every other Pod. This should be an explicit decision, since it's very likely not every service should be able to communicate with every other. The first step is a NetworkPolicy that denies all traffic by default and only allows the frontend to reach the backend. Also, a service mesh with mutual TLS could be used for authenticating and encrypting each request between services. Similarly, we don't have any authentication at the cluster boundary, which would sit in front of the frontend at the Ingress. I'll dig into these topics in Part 2.

3. **Probes would account for slow startup.** The backend's `SLEEP_DURATION` mocks actual startup work. For an ML service, that work might be loading a model, which, depending on the model size, could take quite long. If the liveness probe starts checking before the model finishes loading, Kubernetes restarts the container and the load starts over. A `startupProbe` holds off the liveness and readiness probes until the container has finished starting.
