+++
# Experience widget.
widget = "experience"  # See https://sourcethemes.com/academic/docs/page-builder/
headless = true  # This file represents a page section.
active = true  # Activate this widget? true/false
weight = 30  # Order that this section will appear.

title = "Experience"
subtitle = ""

# Date format for experience
#   Refer to https://sourcethemes.com/academic/docs/customization/#date-format
date_format = "Jan 2006"

# Label for the collapsible description toggle on each role.
details_label = "Details"

# Experiences.
#   Each `[[experience]]` block is ONE COMPANY. Add roles held at that company
#   as nested `[[experience.roles]]` blocks — they render stacked inside a
#   single card, newest first.
#
#   Company block:  `company` (required), `company_url`, `location`, `order`.
#   Role block:     `title` (required), `date_start` (required), `date_end`
#                   (omit or leave empty for a current role), `description`,
#                   `details_open` (true to expand the details by default).
#
#   The company's displayed date span is derived from its roles, so you never
#   have to keep it in sync by hand.
#
#   `order` controls display order (ascending). If the first block sets it,
#   every block must; otherwise the theme sorts by `date_end` descending.

[[experience]]
  order = 1
  company = "Just-Evotec Biologics"
  company_url = "https://just-evotecbiologics.com/"
  location = "Seattle, WA"

  [[experience.roles]]
    title = "Senior Data Platform Engineer"
    date_start = "2025-10-01"
    date_end = ""
    details_open = true
    description = """
   * Modernized the Dagster orchestration platform on AWS ECS, decoupling platform infrastructure from pipeline code for independent deploys and horizontal auto-scaling. Terraform templates cut new-pipeline provisioning from hours to under 5 minutes. Operate 3 production pipelines spanning upstream process development, ERP, and finance.
   * Built and maintain a centralized schema registry: 65+ versioned, backwards-compatible data contracts across instrument ingestion, orchestration pipelines, and lakehouse writes, catching data quality issues at the point of entry before they reach downstream models and analytics.
   * Led data platform integration for a new automated mini-bioreactor platform, a capital investment to improve scale-up analyses, now in production: built the ingestion pipelines, linkage of mini-bioreactor runs to bench- and manufacturing-scale bioreactor data, and the analytical tooling for scale-up comparisons.
   * Own the data lifecycle for two SCADA production databases growing ~100 GB/month: AWS Backup snapshots, Step Functions exports of monthly Parquet snapshots to S3, Glacier tiering, and Athena for historical queries.
   * Architecting a regulatory-grade audit framework (data lineage, write-time schema versioning, user access logs) on immutable DynamoDB stores for on-demand FDA and DoD information requests.
   * Leading design of an experiment-management platform replacing 15+ legacy tools company-wide: a multi-service monorepo of FastAPI backends and a Next.js frontend over PostgreSQL, with shared Pydantic contracts, deployed via Terraform.
    """

  [[experience.roles]]
    title = "Senior Data Scientist"
    date_start = "2022-04-01"
    date_end = "2025-10-01"
    details_open = false
    description = """
   **ML engineering**

   * Designed and built in-house deep learning models for structure-based antibody sequence design (inverse folding): message-passing graph encoder-decoders over protein structure graphs, with autoregressive and parallel samplers for generating candidate sequence designs.
   * Built the distributed training stack (PyTorch DDP / torchrun on multi-GPU Slurm nodes, checkpoint/resume, rank-aggregated metrics, Hydra configs) and ran systematic experiments on masking strategy, model depth, and validation design.
   * Built dataset pipelines to pre-featurize Protein Data Bank complexes (DIPS, DB5, SAbDab) for faster training.
   * Took the model to production as a versioned Python package (unit tests, GitLab CI publishing to an internal registry), containerized and deployed on ECS Fargate.
   * Fine-tuned protein language models for sequence-liability and thermal stability prediction, deployed to production alongside the structure-based design models and versioned in MLflow.

   **Data & platform engineering**

   * Architected a serverless, event-driven AWS ingestion pipeline (S3, EventBridge, Lambda, ECS, SQS) for 7 scientific instruments with near-100% uptime, cutting time from raw assay file to analytics-ready data from days or weeks to under 30 minutes and closing a provenance gap where raw files sat on scientists' laptops.
   * Introduced Terraform as the org-wide infrastructure-as-code standard and led migration of 35+ microservices from EC2 to ECS across test and production environments.
   * Built FastAPI data services, Dagster gold-layer pipelines, and Dash/Plotly dashboards used by 60+ scientists across 6 functional groups.
    """

[[experience]]
  order = 2
  company = "Curi Bio"
  company_url = "https://www.curibio.com/"
  location = "Seattle, WA"

  [[experience.roles]]
    title = "Data Scientist"
    date_start = "2021-06-01"
    date_end = "2022-04-01"
    description = """
   * Developed deep learning models to predict stem cell differentiation outcomes from high-throughput microscopy images, reducing material resource costs by upwards of 25% for the associated research stage.
   * Built contractility waveform analysis pipelines for engineered cardiac and skeletal myocytes, using signal processing to characterize the impact of therapeutics on muscle cell function.
    """

[[experience]]
  order = 3
  company = "University of Washington, Integrated Brain Imaging Center"
  company_url = "http://ibic.washington.edu/#&panel1-1"
  location = "Seattle, WA"

  [[experience.roles]]
    title = "PhD Graduate Student, Biomedical Engineering"
    date_start = "2014-09-01"
    date_end = "2021-06-01"
    details_open = false
    description = """
   * Built a turn-key orchestration pipeline for processing 1000+ functional and diffusion MRI scans (>1.5TB) on a GPU-backed HPC system.
   * Developed graph neural networks for human MRI segmentation and biomarker generation, improving accuracy 15%+ over standard CNNs and improving test-retest reliability of patient-specific segmentations by 6% across clinical scanning sessions.
   * Applied dynamic mode decomposition (DMD) to fMRI brain dynamics, outperforming state-of-the-art ICA at identifying canonical activation networks while requiring shorter scanning sessions.
   * Designed a spatial statistical modeling approach for analyzing variability in the topography of functional brain connectivity, with results aligning with long-standing theories of hierarchical brain organization.
   * Awarded a highly selective 3-year ARCS Washington Research Foundation fellowship.
    """

[[experience]]
  order = 4
  company = "Internships"
  location = "Washington State"

  [[experience.roles]]
    title = "Software Engineering Intern, Phase Genomics"
    date_start = "2017-04-01"
    date_end = "2017-06-01"

  [[experience.roles]]
    title = "Data Science Intern, Pacific Northwest National Laboratory"
    date_start = "2016-06-01"
    date_end = "2016-09-01"
+++
