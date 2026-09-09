+++
# A Skills section created with the Featurette widget.
widget = "featurette"  # See https://sourcethemes.com/academic/docs/page-builder/
headless = true  # This file represents a page section.
active = true  # Activate this widget? true/false
weight = 40  # Order that this section will appear.

title = "Skills and Technologies"
subtitle = ""

# Showcase personal skills or business features.
#
# Add/remove feature blocks below as you like. Four per row at desktop
# width, two on tablets, one on phones.
#
# `description` is Markdown, so a bullet list renders as a real list.
#
# For available icons, see: https://sourcethemes.com/academic/docs/widgets/#icons

[design.background]
  # Apply a background color, gradient, or image.
  #   Uncomment (by removing `#`) an option to apply it.
  #   Choose a light or dark text color by setting `text_color_light`.
  #   Any HTML color name or Hex value is valid.

  # Background color.
  # color = "navy"

  # Background gradient.
  # gradient_start = "DeepSkyBlue"
  # gradient_end = "SkyBlue"

  # Background image.
  # image = "Bayes.jpg"  # Name of image in `static/img/`.
  # image_darken = 0.6  # Darken the image? Range 0-1 where 0 is transparent and 1 is opaque.

  # Text color (true=light or false=dark).
  text_color_light = false

[[feature]]
  icon = "cloud"
  icon_pack = "fas"
  name = "Cloud &amp; Infrastructure"
  description = """
- **Compute:** ECS/Fargate, Lambda; Kubernetes (personal projects)
- **Events &amp; storage:** EventBridge, S3, DynamoDB
- **Access &amp; observability:** IAM, Cognito, CloudWatch
- **Infrastructure as code:** Terraform
"""

[[feature]]
  icon = "project-diagram"
  icon_pack = "fas"
  name = "Data Engineering"
  description = """
- **Orchestration:** Dagster
- **Lakehouse:** Delta Lake, Parquet
- **Transactional stores:** PostgreSQL
- **Governance:** schema registries, versioned data contracts
"""

[[feature]]
  icon = "brain"
  icon_pack = "fas"
  name = "ML &amp; AI"
  description = """
- **Modeling:** PyTorch (DDP), DGL, scikit-learn
- **Tracking &amp; registry:** MLflow
- **Managed LLMs:** Bedrock
- **Applied:** protein language models, graph neural networks
"""

[[feature]]
  icon = "keyboard"
  icon_pack = "fas"
  name = "Applications &amp; Delivery"
  description = """
- **APIs:** FastAPI, Pydantic
- **Frontend:** Next.js, React, TypeScript
- **Build &amp; deploy:** Docker, GitHub Actions CI/CD
- **Practices:** test-driven development, monorepos
"""

+++
