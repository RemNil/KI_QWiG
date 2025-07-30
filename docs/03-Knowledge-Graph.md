# Knowledge Graph

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
    <li> Makin it easier to reason across complex topics by connecting related information</li>
    <li> Bridging large datasets and multiple data sources (e.g., IQWIG benefit assessments, EMA EPARs, G-BA "Tragende Gründe" etc.).</li>
    <li> Facilitate easy information retrieval using Retrieval-Augmented Generation (RAG). </li>
  </ul>
</div>

#### 1. **Data sources** {-}
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
    <li><strong>TL;DR:</strong> PDFs are designed for layout and visual fidelity, not structured data. That makes them painful to parse, especially when dealing with things like tables, multi-column layouts, footnotes, or inconsistent fonts. li>
  </ul>
</div>


#### 2. **Data processing** {-}

- Metadata extraction: JSON
- Concept annotations: important concepts like medical terms, clincial trial vocabulary, study names, common endpoint categories and operationalizations, IQWiG-specific language "Beleg", "Hinweis", "Anhaltspunkt" with core defintion.
- Abbreviation lists: unified glossary of all abbreviations from all tables across all projects
- Hierarchical structure mapping: common sections with content expectations (template), semantic relationships between tabular data, text sections, footnotes etc.


#### 3. **Graph development** {-}

#### 4. **Quality Assurance** {-}

#### 5. **Model deployment** {-}
