---
# Documentation: https://sourcethemes.com/academic/docs/managing-content/

title: "Enabling Custom Jekyll Plugins with TravisCI"
subtitle: ""
summary: ""
authors: []
tags: [Jekyll, CI/CD]
categories: [software engineering]
date: 2018-08-12T02:14:14-07:00
lastmod: 2018-08-13T02:14:14-07:00
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

I just learned about [TravisCI](https://travis-ci.org/) (actually, about continuous integration (CI) in general) after attending [Neurohackademy 2018](http://neurohackademy.org/).  We learned about CI from the perspective of ensuring that your code builds properly when you update files in your packages, incorporate new methods, refactor your code, etc.  Pretty neat.

Fast forward a couple days, and I'm trying to incorporate custom Jekyll plugins into my blog -- I quickly realized GitHub doesn't allow this for security reasons, but I couldn't find  a convenient work-around.  Some posts suggested using a separate repo branch to build the site, and then push the static HTML files up to a remote repo to do the actual hosting, but for some reason I couldn't get that approach to work.

Finally, I saw some mentions of using TravisCI and [CircleCI](https://circleci.com/pricing/?utm_source=gb&utm_medium=SEM&utm_campaign=SEM-gb-200-Eng-ni&utm_content=SEM-gb-200-Eng-ni-Circle-CI&gclid=Cj0KCQjwtb_bBRCFARIsAO5fVvGQIO23w0ahWrTj3v8MrGLEnjI00KcEClqUuQda-Q_cz05h8jjEC5QaAjeREALw_wcB) to build and push the site using continuous integration.  I ended up using the approach suggested by [Josh Frankel](http://joshfrankel.me/blog/deploying-a-jekyll-blog-to-github-pages-with-custom-plugins-and-travisci/).

Josh's site gives a really clear explanation of the necessary steps, given some very minmal prequisite knowledge about using Git.  His instructions actually worked almost perfectly for me, so I won't repeat them again here (just follow the link above, if you're interested) -- however, there were a few issues that arose on my end:

  1. For some reason, I had an ```about.html``` file and ```index.html``` file in the main repo directory -- my built blog wouldn't register any updates I made to ```about.md``` or ```index.md``` while these files were around, so I deleted the HTML files.  This might have been an obvious bug to someone with more web programming experience, but I'm a novice at that.  If you're seeing any wonky behavior, check to make sure you don't have any unnecessary files hanging around.

  2. **Ruby version**:  I had to change the version of Ruby I was using to ```ruby-2.4.1```.

  3. **Plugins**: Make sure any Jekyll plugins you want to use are already installed.

  4. **Emails**: You can turn off email reporting from TravisCI by adding
    ```notifications: email: false``` to your ```.travis.yml``` file.

But now, you can incorporate custom, user-built Jekyll plugins and let TravisCI do the heavy lifting!  I specifically wanted the ability to reference papers using BibTex-style citation links with Jekyll, like you can with LaTex or Endnote -- this capability isn't currently supported by GitHub.  Happy blogging!
