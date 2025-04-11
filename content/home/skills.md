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
# Add/remove as many `[[feature]]` blocks below as you like.
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
  icon = "brain"
  icon_pack = "fas"
  name = "Data Science"
  description = "APIs (FastAPI), Python data stack (numpy, scipy, pandas, etc.), visualization (Dash, Plotly, Streamlit)"

[[feature]]
  icon = "cloud"
  icon_pack = "fas"
  name = "Cloud infrastructure"
  description = "AWS (EC2, ECS, EKS, EventBridge, IAM, Lambda, RDS, S3, SageMaker, VPC), Terraform"
[[feature]]
  icon = "project-diagram"
  icon_pack = "fas"
  name = "Data Engineering"
  description = "AI + ML (Pytorch, DGL), MLOps (MLFlow), deployment (ECS, SageMaker, Lambda), CI/CD (Gitlab), containerization (Docker), orchestration (Dagster), databases (SQL, PySpark)"

[[feature]]
  icon = "keyboard"
  icon_pack = "fas"
  name = "Software Engineering"
  description = "object-oriented design, test-driven development, data structures + algorithms"  

+++
