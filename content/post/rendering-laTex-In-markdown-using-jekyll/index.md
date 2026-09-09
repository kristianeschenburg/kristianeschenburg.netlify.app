---
# Documentation: https://sourcethemes.com/academic/docs/managing-content/

title: "Rendering LaTex In Markdown Using Jekyll"
subtitle: ""
summary: ""
authors: []
tags: [Jekyll, LaTeX]
categories: [software engineering]
date: 2018-08-11T02:14:14-07:00
lastmod: 2018-08-12T02:14:14-07:00
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

In putting together this blog, I wanted to be able to talk about various mathematical topics that I found interesting, which inevitably lead to using LaTex in my posts.

I'm currently using Atom as my editor (having converted from Sublime), and needed to install a bunch of packages first.  First and foremost, I wanted to be able to render my markdown posts before hosting them on the blog, and consequentially needed a way to render LaTex.  For this, I installed a few Atom packages:

  * [Markdown-Preview](https://atom.io/packages/markdown-it-preview )
  * [Latex](https://atom.io/packages/latex)
  * [Language-Latex](https://atom.io/packages/language-latex)

To preview your post in Atom, you just type ```ctrl+shift+M```, which will display both in-line and block math sections.

However, if you build your site locally with the command ```bundle exec jekyll serve``` or push it to a remote repo, the LaTex no longer renders properly.  After Googling around a bit, I determined that this was due to the way markdown converters in Jekyll, like **kramdown** and **redcarpet**, do the conversion using MathJax -- specifically, in-line math segments are not properly rendered.  I wanted a way to both preview the LaTex in Atom, and properly render it usng Jekyll.  I found two links that solved the problem for me:

  * [Visually Enforced](http://www.gastonsanchez.com/visually-enforced/opinion/2014/02/16/Mathjax-with-jekyll/)
  * [LaTeX in Jekyll](http://www.iangoodfellow.com/blog/jekyll/markdown/tex/2016/11/07/latex-in-markdown.html)

In short, the following steps solved the problem of LaTex not rendering for me.  I'm using the **minima** theme, so I first found the theme directory with ```bundle show minima```.  In this directory, I copied the **./layouts/post.html** to a local directory in my project folder called **./\_layouts/post.html**.

Within this file, I pasted the following two sections of HTML code:

```html
<script type="text/x-mathjax-config">
    MathJax.Hub.Config({
      tex2jax: {
        skipTags: ['script', 'noscript', 'style', 'textarea', 'pre'],
        inlineMath: [['$','$']]
      }
    });
  </script>
<script src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML" type="text/javascript"></script>
```

And voila -- building the posts now correctly renders LaTex!
