# 🐍 Python Naming Conventions Cheat Sheet

A concise reminder for when to use **underscore (`_`)** vs **hyphen
(`-`)**, and how to name things consistently in Python projects.

------------------------------------------------------------------------

## 1️⃣ General Rule of Thumb

  ------------------------------------------------------------------------
  Context                      Use            Example
  ---------------------------- -------------- ----------------------------
  Inside Python code (imports, **Underscore   `train_model`,
  functions, variables)        `_`**          `data_loader.py`

  Outside Python (repo,        **Hyphen `-`** `rag-pipeline-visualizer`,
  folder, CLI, URLs)                          `nlp-learning`
  ------------------------------------------------------------------------

------------------------------------------------------------------------

## 2️⃣ File, Folder, and Module Naming

  ----------------------------------------------------------------------------
  Type            Convention                       Example
  --------------- -------------------------------- ---------------------------
  Python          lowercase with underscores       `data_cleaning.py`,
  file/module                                      `model_utils.py`

  Python package  lowercase with underscores       `feature_engineering/`
  (folder)                                         

  Git repo /      lowercase with hyphens           `nlp-learning`,
  top-level                                        `rag-pipeline-visualizer`
  folder                                           

  Config /        lowercase with hyphens           `docker-setup/`,
  non-Python                                       `web-assets/`
  folder                                           
  ----------------------------------------------------------------------------

📌 **Note:**\
Hyphens (`-`) are **not valid** in import statements.\
✅ `import data_cleaning`\
❌ `import data-cleaning`

------------------------------------------------------------------------

## 3️⃣ Variable & Function Names

  -------------------------------------------------------------------------------
  Type                Convention                       Example
  ------------------- -------------------------------- --------------------------
  Variable            `snake_case`                     `num_samples`, `max_depth`

  Function            `snake_case`                     `train_model()`,
                                                       `load_dataset()`

  Private             `_single_leading_underscore`     `_cache_results()`
  variable/function                                    

  Temporary / ignored `_`                              `for _ in range(5): ...`
  variable                                             
  -------------------------------------------------------------------------------

------------------------------------------------------------------------

## 4️⃣ Class & Constant Names

  Type              Convention                      Example
  ----------------- ------------------------------- ------------------------------------
  Class             `PascalCase`                    `CustomerSegmenter`, `DataCleaner`
  Constant          `UPPER_CASE_WITH_UNDERSCORES`   `MAX_ITERATIONS = 1000`
  Exception Class   `PascalCase` + `Error`          `DataValidationError`

------------------------------------------------------------------------

## 5️⃣ CLI, URLs, and Configs

  -------------------------------------------------------------------------------------------------
  Type            Convention                       Example
  --------------- -------------------------------- ------------------------------------------------
  CLI command     lowercase with hyphens           `pip install my-package`,
                                                   `streamlit run rag-pipeline-visualizer/app.py`

  URL slug        lowercase with hyphens           `https://example.com/rag-pipeline-visualizer`

  YAML / JSON key lowercase with hyphens or        `pipeline-name: rag-pipeline-visualizer` or
                  underscores                      `pipeline_name: rag_pipeline_visualizer`
  -------------------------------------------------------------------------------------------------

------------------------------------------------------------------------

## 6️⃣ Folder & Import Example

``` bash
nlp-learning/
│
├── rag-pipeline-visualizer/   # hyphen for folder name (external)
│   ├── app.py
│   ├── data_loader.py         # underscore (Python file)
│   └── model_utils.py
└── text_cleaning/
    └── preprocess_text.py
```

``` python
# Inside Python code
from text_cleaning.preprocess_text import clean_text
from rag_pipeline_visualizer.model_utils import visualize_rag_pipeline
```

------------------------------------------------------------------------

## 7️⃣ Special Underscore Conventions in Python

  -----------------------------------------------------------------------
  Pattern                             Meaning
  ----------------------------------- -----------------------------------
  `_var`                              "Internal use" variable (by
                                      convention, not enforced)

  `var_`                              Avoids name conflict with keyword
                                      (e.g., `class_`)

  `__var`                             Name-mangled (used in classes to
                                      avoid conflicts)

  `__var__`                           Reserved for built-in special
                                      methods (`__init__`, `__str__`)
  -----------------------------------------------------------------------

------------------------------------------------------------------------

## ✅ Summary

-   Use `_` inside Python code.\
-   Use `-` outside Python (folders, repos, commands).\
-   Follow **PEP 8** naming style for consistency.\
-   Avoid spaces and uppercase letters in filenames or folders.\
-   Keep names short, descriptive, and consistent across your project.

------------------------------------------------------------------------

**Author:** Muhammad Cikal Merdeka\
**Purpose:** Quick reference for clean and consistent Python project
naming conventions.
