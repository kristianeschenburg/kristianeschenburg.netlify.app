---
# Documentation: https://sourcethemes.com/academic/docs/managing-content/

title: "Two Weeks of Open Science: A Rekindled Flame"
subtitle: ""
summary: ""
authors: []
tags: [open science]
categories: [neuroscience]
date: 2018-08-17T01:12:33-07:00
date: 2018-08-18T01:12:33-07:00
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

I recently attended [Neurohackademy 2018](http://neurohackademy.org/), hosted by the University of Washington's [eScience Institute](https://escience.washington.edu/), and organized by Dr. Ariel Rokem and Dr. Tal Yarkoni.

This was a 2-week long event, beginning with a series of daily lectures, and ending with a fast-paced, high-intensity scramble to put together a beta (but working) version of some project coupling neuroimaging with software development.  The lectures varied in topic, from how to test academic code and how to organize open source projects, to machine learning and algorithms for low-dimensional representations of neural recordings, to neuroethics (full lecture list [here](https://neurohackademy.org/neurohack_year/2018/)).

Many of the lecturers are scientists and developers who I've looked up to for years -- a few have even been my intellectual, and now post-Neurohackademy, philosophical role models.  While the lectures were enlightening in their own right, there was a level of intimacy during these 2 weeks that's been unmatched during grad school so far.  Rarely do young researchers like myself get to pick the brains of and engage in scientific banter with scientists whose papers they read, or whose updates they follow, in such a fluid and collaborative setting.  I feel a little weird being so enthusiastic about it (specifically because I know some of them might read this), but (and I think I speak for all of us who participated) it was a richly rewarding experience.
<br/>

{{< figure src="Couch_RickMorty.png" title="" lightbox="true" >}}

The [#NH18](https://twitter.com/search?q=%23nh18&src=tyah) participants varied in status from graduate students, to post-docs, to industry members, and traveled from all around the world to Seattle, but each one of us was, in one way or another, involved with neuroscience research.  As one of my new friends put it on Twitter: ["Spent yesterday in a room full of relative strangers who were collaborating, mentoring, & supporting. Devoid of egos or tribalism. Feels like what science (& society) should be."](https://twitter.com/rxxqx/status/1027238653662093313)  The sense of community was strong, positivity was plentiful, and people supported one another -- without regard for experience or any sense of *return-on-investment*.  We had an established **Git person**, **Python person**, **data viz person**, **fMRI person**, **C++ person**, etc. -- if you had a question or ran into an issue, with high probability there was someone who could and would help you out.  Everyone was genuinely excited to learn, to share, to create, to bond, and especially, *~to neuro/computer/data-science~*.

  --- **to science** ---
  - (origin: probably Newton)
  - *verb*. To perform scientific research, almost always in a smooth or cool way.

I worked on a project directly related to my research, but that I'd only previously written some messy, non-shareable scripts for.  Conveniently, my co-NeuroHacker [Michael Notter](https://twitter.com/miyka_el) had a similar idea and we hit the ground running with some of our colleagues.  The project, titled [parcellation_fragmenter](https://kristianeschenburg.github.io/parcellation_fragmenter/), provides a means for fragmenting the brain cortex into a predefined number of regions, or a set of regions each of the same size.  These regions can be anatomically constrained, or arbitrarily spread across the cortex.  Our goal was to use this tool to speed up statistical tests, like [SearchLight FDR](https://www.ncbi.nlm.nih.gov/pubmed/17825583), or as a feature extraction method for down-stream machine learning applications.  I'm currently using this tool to examine how cortical network resolution impacts pairwise regional network properties.

<blockquote class="twitter-tweet tw-align-center" data-lang="en" display="block" margin-left="auto" margin-right="auto"><p lang="en" dir="ltr">Here is something pretty! It was created with the new parcellation fragmenter (<a href="https://t.co/9VLCpr336Y">https://t.co/9VLCpr336Y</a>), developed by Kristian Eschenburg, <a href="https://twitter.com/kako_toro?ref_src=twsrc%5Etfw">@kako_toro</a>, Amanda Sidwell &amp; me during the <a href="https://twitter.com/hashtag/NHW18?src=hash&amp;ref_src=twsrc%5Etfw">#NHW18</a>. Thank&#39;s to <a href="https://twitter.com/hashtag/nilearn?src=hash&amp;ref_src=twsrc%5Etfw">#nilearn</a> &amp; <a href="https://twitter.com/hashtag/nibabel?src=hash&amp;ref_src=twsrc%5Etfw">#nibabel</a> creating this toolbox was straightforward and a lot of fun! <a href="https://t.co/LdqTCMSyrJ">pic.twitter.com/LdqTCMSyrJ</a></p>&mdash; Michael Notter (@miyka_el) <a href="https://twitter.com/miyka_el/status/1028027334245285889?ref_src=twsrc%5Etfw">August 10, 2018</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

My most important takeaway from our project was learning how to collaboratively write and develop software with a group of people.  Not only did each of our team members have unique ideas about how to approach our specific problem, we also each had different ways of thinking about *how to write software in general*.  Clear communication, open-mindedness, and understanding on all of our parts were integral to seeing this development through.  Overall, the project was a success!

Here are a few things I learned, that I'm going to incorporate into my own work (and hopefully convince people in my lab to do the same):

  * Unit-test my code using ```pytest``` and ```nose```
  * Incorporate continuous integration (I've already made use of [TravisCI]({{< relref "/post/enabling-custom-jekyll-plugins/index.md" >}})!)
  * Learn web-dev, and specifically, JavaScript (to use D3, and develop interactive posters and publications)
  * Contribute to issues / create pull-requests on GitHub repos that I use or find interesting
  * Pre-register my papers and submit to open-source journals

This event was what I'd hoped graduate school would be like all along.  While idealistic and naive to some degree, I still think it can be.  The open-source model is shifting how research is performed -- the act of doing research is evolving in such a way that it is no longer tethered to specific institutions or labs, and given tools like Docker and AWS, you can almost perfectly recreate specific computing environments needed to perform the work.  With the rise of open-source datasets, especially due to researchers willingly distributing their data and code, collaborative environments like that fostered by Neurohackademy (even if digital), and the ability to replicate workflows, results, and analyses, are becoming more and more feasible.  It only takes a few proponents of the open-source model to give the idea momentum.

If this is the future, the future is looking good.

