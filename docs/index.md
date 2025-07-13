---
title: ""
author: "Merlin Bittlinger"
date: "2025-07-14"
description: Test. Learn. Repeat.
github-repo: RemNil/remnil.github.io
documentclass: book
link-citations: yes
bibliography: book.bib
site: bookdown::bookdown_site
biblio-style: apalike
split_bib: no
url: https://remnil.github.io/
header-includes:
  \usepackage{float}
---

# Preface {-}
This project leverages AI-tools on publicly available data generated using a transparently published health technology assessment methodology [@IQWiG2023]

"Dossier-Graph": Build a government-grade, opensource RAG system (Knowledge Graph) for research and education

<p style="float: right; margin: 0 0 1em 1em;">
  <img src="images/GRAF.jpeg" width="190px">
</p>

- Store and retrieve documents, tables, and structured knowledge using: 

  - MongoDB for metadata + hierarchy

  - Qdrant for vector search (via Llama embeddings)

  - SuperDuper for another orchestration layer

- Allow flexible but traceable linking between:

  - Main dossiers, Addenda, tables, sections, etc. including complex conceptual linkage

- Human-readable AND machine-consumable paths


The project aims to turn a large archive of dossier evaluations into an intelligent, searchable knowledge database using AI. This replaces slow, manual document review with automated extraction, semantic search, and interactive analysis. 

Users can ask questions in natural language and receive instant, comprehensive answers across all documents. The solution is fully internal, secure, and compliant with data protection standards. It uses open-source tools, is cost-effective, and can easily expand as more documents are added. The main benefits are faster access to information, better pattern recognition, and preservation of institutional knowledge—all while maintaining full control over the data.

## Why it matters {-}
### Drug development and regulation as a learning system {-}
Clinical development of new medicinal products is different from many other business models in that it critically depends on voluntary or even [altruistic](https://onlinelibrary.wiley.com/doi/abs/10.1353/hcr.0.0164) [@jansen2009ethics] research participation and hence on [public trust](https://academic.oup.com/bjps/advance-article-abstract/doi/10.1093/bjps/axz023/5524669?redirectedFrom=fulltext). *"Information gain per unit of accepted research burden"* is a useful concept [introduced](https://www.youtube.com/watch?v=5ECTE0gbwFU=0m52s) to think about how the current regulatory oversight system learns from past [clinical R&D efforts](https://www.ema.europa.eu/en/documents/other/laboratory-patient-journey-centrally-authorised-medicine_en.pdf). A prerequisite of earning public trust. Information cannot only be gained from performing clinical research but throughout the entire regulatory process including post-marketing health technology assessment. Hence, research responsibilities to make most out of the available information extends far beyond the publishing study results. 

<p style="float: right; margin: 0 0 1em 1em;">
  <img src="https://media.giphy.com/media/niL4NM57bz2gw/giphy.gif" width="190px">
</p>

In this spirit the knowledge graph (Dossier-Graph) 
aims to help rendering the available post-marketing health technology assessment information actionable for gaining deep insights about the current research state to which so many patients voluntarily contributed. 

Information gain is increased if state-of-the-art information technology is leveraged at all steps of the drug development and regulation process. This projects contributes to this agenda by providing a AI-based knowledge graph of German HTA reports.

The remainder of this project documentation is written in German.



### Found a mistake? {-}
[Open peer-review](http://www.openreviewtoolkit.org/) is enabled in this project using [hypothes.is](https://web.hypothes.is/). This allows sentence-by-sentence annotation from readers directly on this page. Please feel free to annotate. Both constructive and destructive criticism is [highly welcome](http://www.youtube.com/watch?v=ztmvtKLuR7I&t=10m48s).
