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
   * Modernized the Dagster orchestration platform on AWS ECS, decoupling pipeline infrastructure from application code for independent deployability and horizontal auto-scaling. Cut pipeline provisioning from hours to under 5 minutes via reusable infrastructure templates covering sensors, schedules, and triggers.
   * Built and maintain a centralized schema registry enforcing versioned, backwards-compatible data contracts across 65+ schemas spanning instrument ingestion, orchestration pipelines, and lakehouse writes. Upstream validation catches quality issues at the point of entry, before bad data reaches downstream models and analytics.
   * Architecting a regulatory-grade audit framework covering data lineage, schema versioning at write time, and user access logging, persisted to immutable DynamoDB stores, designed to enable rapid response to FDA and DoD information requests.
   * Building a unified experiment management platform that consolidates sample planning, assay requests, run tracking, planned-vs-actual reconciliation, and reporting into one surface, replacing 6+ fragmented legacy interfaces. A multi-service monorepo (FastAPI, Next.js/React, shared Pydantic contracts) over multi-schema PostgreSQL, deployed via Terraform.
    """

  [[experience.roles]]
    title = "Senior Data Scientist"
    date_start = "2022-04-01"
    date_end = "2025-10-01"
    details_open = true
    description = """
   * Architected a serverless, event-driven AWS instrument ingestion pipeline (S3, EventBridge, Lambda, ECS) onboarding 7 scientific instruments, reducing time from assay file generation to analytics-ready data from days or weeks to under 30 minutes. Eliminated a data provenance risk where raw assay files previously sat on scientists' laptops with no version control or traceability.
   * Delivered 3 production ML models for antibody design and property prediction, including fine-tuned masked protein language models and graph neural networks trained on protein structure data. Trained with PyTorch DDP on in-house GPU HPC; deployed as horizontally scalable inference endpoints on ECS Fargate and Lambda, tracked with MLflow.
   * Built and deployed FastAPI data APIs, Dagster orchestration pipelines, and visualization dashboards now used by 60+ scientists across 6 functional groups, replacing manual data-sharing workflows and ad hoc reporting with standardized, always-available data access.
   * Introduced Terraform as the company's infrastructure-as-code standard, now adopted org-wide across data science, data engineering, and software engineering. Built reusable modules for ECS/Fargate services, CI/CD, and application infrastructure, cutting deployment time from hours to minutes across dev, staging, and production.
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
    date_end = "2021-09-01"
    details_open = true
    description = """
   * Developed graph neural networks for human MRI segmentation and biomarker generation, improving accuracy 15%+ over standard CNNs and improving test-retest reliability of patient-specific segmentations by 6% across clinical scanning sessions.
   * Applied dynamic mode decomposition (DMD) to fMRI brain dynamics, outperforming state-of-the-art ICA at identifying canonical activation networks while requiring shorter scanning sessions.
   * Designed a spatial statistical modeling approach for analyzing variability in the topography of functional brain connectivity, with results aligning with long-standing theories of hierarchical brain organization.
   * Built a turn-key orchestration pipeline for processing 1000+ functional and diffusion MRI scans (>1.5TB) on a GPU-backed HPC system.
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
