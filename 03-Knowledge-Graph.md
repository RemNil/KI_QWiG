# Knowledge Graph

If we trust the data, we should use it.

<style>
div.blue {
  background-color: #e6f0ff;
  border-radius: 5px;
  padding: 20px;
  margin-bottom: 10px; /* adds vertical space below the box */
}
</style>
<div class = "blue">
  <h4>Key features of Knowledge Graphs</h4>
  <ul>
    <li> Making it easier to reason across complex topics by connecting related information</li>
    <li> Bridging large datasets and multiple data sources (e.g., IQWIG benefit assessments, EMA EPARs, G-BA "Tragende Gründe" etc.).</li>
    <li> Facilitate easy information retrieval using Retrieval-Augmented Generation (RAG). </li>
  </ul>
</div>

So, yada, yada.

## Data sources

Data is in the public domain and can be webscraped for academic/educational noncommercial use (https://github.com/RemNil/Dossier-Graph)

However, all source data is publish as PDF files. PDFs are difficult to work with because they store visual layout rather than structured content. Unlike Word or HTML, PDFs lack semantic tags like headings, paragraphs, or tables—they simply position text on a page. This makes it hard to extract meaningful data, especially from tables or multi-column layouts, since there's no inherent reading order or logical structure. In contrast, formats like `.docx`, HTML, or JSON are designed for structured content and are far easier to parse programmatically.

<style>
div.red {
  background-color: #FFE6F0;
  border-radius: 5px;
  padding: 20px;
  margin-bottom: 10px; /* adds vertical space below the box */
}
</style>
<div class = "red">
  <h4>Key limitations</h4>
  <ul>
    <li><strong>TL;DR:</strong> PDFs are designed for layout and visual fidelity, not structured data. That makes them painful to parse, especially when dealing with things like tables, multi-column layouts, footnotes, or inconsistent fonts. </li>
  </ul>
</div>

Exactly?


## Data processing

Parsing complex scientific documents like IQWiG reports requires more than generic PDF extraction — especially when dealing with long text passages, dense tabular data, and nuanced medical terminology. Unlike journal articles that often follow a typical standardized structure (Abstract, Methods, Results, etc.), IQWiG reports follow their own template-based structure, with institution-specific conventions, recurring section types, and domain-specific vocabulary. This necessitates a tailored but flexible, hybrid processing pipeline that combines layout-aware extraction with semantic parsing and structured data representation.

IQWiG reports typically span dozens of pages (often 80+), and blend narrative analysis, evaluation of clinical trials, and formal assessments with dense tabular data, footnotes, and abbreviations. Off-the-shelf tools like GROBID — while excellent for standardized scientific literature — might be too rigid for such documents, as they assume a publication layout seen in PubMed or conference papers. Making GROBID adaptable to custom headings, IQWiG-specific terminologies like “Beleg” or “Hinweis”, or non-standard section structures is non-trivial.

Instead, a hybrid strategy appears far more promising. Tools like pdfplumber and PyMuPDF offer reliable access to the visual structure of each page, allowing precise control over table extraction, bounding box analysis, and text block sequencing (with non-trivial fine tuning demands as well for messy tabular content etc). Meanwhile, unstructured.io provides high-level chunking capabilities, converting narrative content into semantically tagged elements such as NarrativeText, Title, List, or Table. This dual approach allows the processing to be tailored per content type: text-heavy sections can be routed to semantic analysis, while table-heavy pages can be extracted, cleaned, and converted to structured formats like CSV or JSON.

Given the volume and complexity publicly available IQWiG or G-BA corpora — 1,500 to up to 5,000 PDFs — a modular pipeline architecture is essential. The strategy should begin by segmenting each document into page-level or section-level units, identifying which parts contain predominantly tabular data, and which contain explanatory or evaluative text. This content-type segmentation allows for targeted processing: table pages can be handled using pdfplumber or camelot with post-processing to normalize headers and cell values, while text sections are parsed with unstructured.io, producing rich, metadata-tagged chunks suitable for indexing, embedding, or further NLP.

Key features of the processing pipeline:

### Metadata Extraction

Each document should be parsed to extract bibliographic and structural metadata into a consistent JSON schema — including document title, project code, report type, section labels, page ranges, and table/figure references.

### Concept Annotation

Leveraging either spaCy (with medical or German-language models) or a domain-adapted LLM, key concepts such as medical terms, study identifiers, clinical endpoints, and IQWiG-evaluative language ("Hinweis", "Beleg", etc.) can be tagged. These annotations serve as candidates for a downstream knowledge graph.

### Abbreviation List Extraction

A glossary of abbreviations should be built by automatically detecting and parsing abbreviation-definition pairs from designated sections and table footnotes, aggregating terms across documents into a unified dictionary.

### Structural Hierarchy Preservation

Despite lacking standard journal layout, IQWiG reports do follow a templated structure, often with consistent headings and expected subtopics. The pipeline should use rule-based or ML-aided logic to detect section boundaries and maintain the document’s semantic hierarchy. This is crucial for maintaining links between a given table and the explanatory text surrounding it, as well as connecting conclusions with referenced studies or findings.

### Semantic Integration of Tables and Text

Tables in these documents are not standalone — they are tightly linked to claims, evidence categories, and footnote-based qualifiers. The PDF processing should be able to identify these cross-references, potentially through heuristics (e.g., detecting references like “siehe Tabelle 4”) or embedding-based similarity matching between tabular rows and narrative mentions.

Overall, the goal is not just extraction, but understanding — to transform complex, long-form PDF reports into structured, semantically enriched data that supports both human and machine reasoning. This requires precision, modularity, and a pipeline that is aware of the domain’s unique characteristics.

The true challenge is using a hybrid strategy: 1) layout-first tools for precision (like pdfplumber), and 2) semantic-aware chunkers (like unstructured.io) and breaking down the worklfow into specialized processing flows for text, tables, metadata, and glossary content.

```plaintext
iqwig_pdf_pipeline/
├── data/
│   ├── raw_pdfs/                  # Your original IQWiG PDFs here
│   ├── extracted_tables/          # JSON/CSV tables extracted per PDF
│   ├── extracted_text_chunks/     # Semantic text chunks (JSON)
│   └── metadata/                  # Metadata JSON files
│
├── notebooks/
│   └── exploration.ipynb          # For prototyping parsing ideas
│
├── scripts/
│   ├── pdf_splitter.py            # Identify table vs text pages, split PDFs
│   ├── table_extractor.py         # Extract & clean tables (pdfplumber/camelot)
│   ├── text_chunker.py            # Chunk narrative text (unstructured.io)
│   ├── abbreviation_extractor.py  # Detect and unify abbreviation lists
│   ├── concept_annotator.py       # Annotate medical terms, IQWiG vocab etc.
│   ├── metadata_extractor.py      # Extract metadata to JSON
│   └── pipeline_runner.py         # Master script that runs all modules
│
├── models/
│   └── spacy_models/              # Domain-adapted spaCy or custom NER models
│
├── requirements.txt               # Python dependencies
├── README.md
└── config.yaml                   # Pipeline configs (paths, thresholds, etc.)
```

## Graph development

## Quality Assurance

## Model deployment
