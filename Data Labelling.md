# Data Labelling
### The Foundation of Supervised Machine Learning

> *Every great model starts with great labels. Garbage in, garbage out — no architecture can fix bad ground truth.*

---

## What is Data Labelling?

**Data labelling** (also called data annotation) is the process of adding meaningful tags, categories, or structured metadata to raw data so that machine learning models can learn from it. It is the bridge between raw, unstructured data and the supervised learning algorithms that power modern AI systems.

Without labelled data, supervised learning simply cannot exist. Every image classifier, sentiment model, named entity recognizer, and object detector in production today was trained on data that a human — or a combination of humans and automated tools — sat down and labelled.

### Why It Matters More Than You Think

It is tempting to focus on model architecture, hyperparameters, and training pipelines. But in practice, **data quality is the single biggest lever on model performance.** Research across the industry has consistently shown that:

- A state-of-the-art model trained on noisy labels will underperform a simpler model trained on clean labels
- Mislabelled data introduces irreducible error — a ceiling that no amount of regularization or fine-tuning can break through
- The cost of fixing label errors compounds downstream: a bad label in training can mean a bad prediction in production, and a bad prediction can mean a bad business decision

---

## The Data Labelling Workflow

Regardless of domain or data type, most labelling pipelines follow a common structure:

```
Raw Data Collection
        ↓
Label Schema Design
(what categories? what granularity?)
        ↓
Annotator Assignment
(human labellers, crowdsourcing, or automated tools)
        ↓
Annotation
        ↓
Quality Control & Review
(inter-annotator agreement, expert review)
        ↓
Label Consolidation
        ↓
Model Training
        ↓
Active Learning Loop (optional)
(model flags uncertain samples → human reviews → labels updated)
```

---

## Core Labelling Concepts

### Label Types

| Label Type | Description | Example |
|---|---|---|
| **Binary** | One of two classes | Spam / Not Spam |
| **Multi-class** | One of N exclusive classes | Sentiment: Positive / Neutral / Negative |
| **Multi-label** | Multiple classes can apply simultaneously | A tweet tagged as: sarcasm + complaint + product mention |
| **Ordinal** | Ordered categories with meaningful rank | Review rating: 1 ★ → 5 ★ |
| **Sequence** | Per-token labels on ordered data | NER: each word gets its own tag |
| **Bounding box** | Rectangular region label in an image | Object detection |
| **Polygon / Segmentation** | Pixel-level label in an image | Semantic / instance segmentation |
| **Keypoint** | Specific coordinate labels | Human pose estimation |

---

### Label Quality Metrics

Before trusting any labelled dataset, these metrics should be evaluated:

#### Inter-Annotator Agreement (IAA)

Measures how consistently different annotators label the same data. A fundamental proxy for label quality.

```python
# Cohen's Kappa — agreement between 2 annotators, corrected for chance
from sklearn.metrics import cohen_kappa_score

annotator_1 = [1, 0, 1, 1, 0, 1, 0, 0, 1, 1]
annotator_2 = [1, 0, 1, 0, 0, 1, 1, 0, 1, 1]

kappa = cohen_kappa_score(annotator_1, annotator_2)
print(f"Cohen's Kappa: {kappa:.3f}")
```

**Interpreting Kappa:**

| Kappa Value | Agreement Level |
|---|---|
| < 0.00 | Less than chance |
| 0.00 – 0.20 | Slight |
| 0.21 – 0.40 | Fair |
| 0.41 – 0.60 | Moderate |
| 0.61 – 0.80 | Substantial |
| 0.81 – 1.00 | Almost perfect |

> For most production NLP tasks, aim for κ ≥ 0.70. For medical or safety-critical computer vision tasks, κ ≥ 0.80 is the standard.

#### Label Error Rate

The estimated fraction of labels in the dataset that are incorrect.

```python
# Using Cleanlab to detect label errors in a trained classifier
from cleanlab.classification import CleanLearning
from sklearn.linear_model import LogisticRegression

cl = CleanLearning(LogisticRegression())
cl.fit(X_train, y_train)

label_issues = cl.get_label_issues()
print(label_issues[label_issues["is_label_issue"]].head())
# Returns rows likely to be mislabelled
```

---

## Part 1: Data Labelling for NLP

Natural Language Processing tasks require labelling **text** — ranging from assigning a single category to an entire document, down to tagging individual characters within a token.

### 1.1 Text Classification

The simplest form of NLP labelling. A human reads a piece of text and assigns it to one or more predefined categories.

**Common tasks:**
- Sentiment analysis (Positive / Negative / Neutral)
- Topic classification (Finance / Sports / Politics / Tech)
- Intent detection (Book flight / Cancel order / Track package)
- Toxicity detection (Toxic / Non-toxic)

**Label format:**
```json
{
  "text": "The delivery was two weeks late and the product was broken.",
  "label": "negative",
  "confidence": 0.95
}
```

**Labelling considerations:**
- Define clear, unambiguous guidelines for edge cases before annotation begins
- Include worked examples in annotator instructions
- Mixed-sentiment text (e.g., "Great product but terrible shipping") needs explicit handling rules
- Class imbalance in labels will mirror class imbalance in training data — over-sample or re-weight accordingly

---

### 1.2 Named Entity Recognition (NER)

NER labelling assigns a tag to each **token** (word or sub-word) in a sequence, identifying spans of text that refer to specific entity types.

**Common entity types:**
- `PER` — Person names
- `ORG` — Organizations
- `LOC` / `GPE` — Locations / Geopolitical entities
- `DATE` / `TIME` — Temporal expressions
- `MONEY` / `PERCENT` — Numeric entities
- Custom domain entities: `DRUG`, `GENE`, `PRODUCT`, `LAW`

**BIO Tagging Scheme** — the most widely used format:

```
Token       Label
---------   -------
Apple       B-ORG      ← Beginning of an ORG entity
Inc.        I-ORG      ← Inside the same ORG entity
released    O          ← Outside any entity
the         O
iPhone      B-PRODUCT  ← Beginning of a PRODUCT entity
15          I-PRODUCT
in          O
September   B-DATE
2023        I-DATE
.           O
```

**Variants:** BIOES (Begin / Inside / Outside / End / Single) provides more granularity for nested or single-token entities.

**Labelling considerations:**
- Nested entities (e.g., "University of California, Berkeley" contains both an ORG and a GPE) require explicit schema decisions
- Consistency in span boundaries is critical — "New York" vs. "New York City" must be handled uniformly
- Domain-specific NER (biomedical, legal, financial) requires subject-matter expert annotators

**Python example — loading a NER-labelled dataset:**
```python
import datasets

# HuggingFace CoNLL-2003 benchmark NER dataset
dataset = datasets.load_dataset("conll2003")
example  = dataset["train"][0]

print(example["tokens"])
# ['EU', 'rejects', 'German', 'call', 'to', 'boycott', 'British', 'lamb', '.']
print(example["ner_tags"])
# [3, 0, 7, 0, 0, 0, 7, 0, 0]
# 0=O, 3=B-ORG, 7=B-MISC (mapped from BIO scheme)
```

---

### 1.3 Relation Extraction

Goes beyond NER to label the **semantic relationship** between identified entities within the same text span.

**Example:**
```
"Elon Musk founded SpaceX in 2002."

Entity 1: "Elon Musk"   → PER
Entity 2: "SpaceX"      → ORG
Relation: FOUNDED_BY
```

**Label format:**
```json
{
  "text": "Elon Musk founded SpaceX in 2002.",
  "entities": [
    {"span": [0, 9],  "label": "PER", "text": "Elon Musk"},
    {"span": [18, 24], "label": "ORG", "text": "SpaceX"}
  ],
  "relation": {
    "type": "FOUNDED_BY",
    "subject": "SpaceX",
    "object": "Elon Musk"
  }
}
```

**Labelling consideration:** Relation schemas must be carefully scoped — overly fine-grained relation types lead to low IAA and inconsistent labels.

---

### 1.4 Coreference Resolution

Labels which mentions in a text **refer to the same real-world entity.**

```
"Barack Obama was born in Hawaii.
 He served as the 44th President of the United States.
 The former president now lives in Washington D.C."

Coreference chain:
  → "Barack Obama" = "He" = "The former president"
```

This is among the hardest NLP labelling tasks because it requires reading the entire document context and making judgment calls about ambiguous pronouns.

---

### 1.5 Textual Entailment / NLI

Given a **premise** and a **hypothesis**, label their logical relationship.

| Label | Meaning |
|---|---|
| **Entailment** | The hypothesis is necessarily true given the premise |
| **Contradiction** | The hypothesis is necessarily false given the premise |
| **Neutral** | The relationship cannot be determined from the premise alone |

**Example:**
```
Premise:    "All dogs in the shelter were adopted last weekend."
Hypothesis: "Some dogs found new homes recently."
Label:       Entailment
```

**Application:** NLI datasets are used to train and evaluate models for question answering, fact verification, and dialogue systems.

---

### 1.6 Span Labelling / Reading Comprehension (QA)

Given a **context passage** and a **question**, the annotator highlights the exact span within the passage that answers the question.

```json
{
  "context": "The Eiffel Tower is located in Paris, France. It was completed in 1889.",
  "question": "When was the Eiffel Tower completed?",
  "answer": {
    "text": "1889",
    "answer_start": 66
  }
}
```

**Tools:** Annotation platforms like Label Studio, Prodigy, and Doccano support span highlighting with character-offset capture.

---

### NLP Labelling Tools

| Tool | Type | Best For |
|---|---|---|
| **Label Studio** | Open-source | General-purpose NLP & CV annotation |
| **Prodigy** | Commercial | Fast annotation with active learning (spaCy ecosystem) |
| **Doccano** | Open-source | Text classification, NER, sequence-to-sequence |
| **Brat** | Open-source | NER and relation extraction |
| **Amazon SageMaker Ground Truth** | Managed cloud | Large-scale NLP labelling with workforce management |
| **Scale AI** | Managed service | Enterprise NLP annotation with QA pipeline |

---

## Part 2: Data Labelling for Computer Vision

Computer Vision labelling deals with **images and video** — requiring annotators to precisely mark spatial regions, boundaries, or points that correspond to objects or features of interest.

### 2.1 Image Classification

The simplest CV labelling task — assign one or more category labels to an entire image.

```
image_001.jpg  →  "cat"
image_002.jpg  →  "dog"
image_003.jpg  →  "cat", "outdoor"   (multi-label)
```

**Label format (standard):**
```json
{
  "image_id": "img_001",
  "file_name": "image_001.jpg",
  "labels": ["cat"],
  "split": "train"
}
```

**Labelling considerations:**
- Establish a visual style guide with reference images for each class — text descriptions alone are insufficient
- Define handling rules for ambiguous images (partially visible objects, poor lighting)
- Avoid label leakage from metadata (filename, EXIF data, image hash)

---

### 2.2 Object Detection

Annotators draw **bounding boxes** around every instance of target objects in an image and assign each box a class label.

**Bounding box format (COCO standard):**
```json
{
  "image_id": 42,
  "annotations": [
    {
      "id": 1,
      "category_id": 3,
      "bbox": [x_min, y_min, width, height],
      "bbox": [120, 85, 200, 150],
      "area": 30000,
      "iscrowd": 0
    }
  ]
}
```

**Common formats:**

| Format | Representation | Used By |
|---|---|---|
| **COCO** | `[x_min, y_min, width, height]` | COCO dataset, detectron2 |
| **Pascal VOC** | `[x_min, y_min, x_max, y_max]` | XML, traditional CV pipelines |
| **YOLO** | `[x_center, y_center, width, height]` (normalized 0–1) | YOLO family models |

**Converting between formats:**
```python
def coco_to_yolo(bbox, img_width, img_height):
    """Convert COCO [x_min, y_min, w, h] to YOLO [x_c, y_c, w, h] normalized."""
    x_min, y_min, w, h = bbox
    x_center = (x_min + w / 2) / img_width
    y_center  = (y_min + h / 2) / img_height
    w_norm    = w / img_width
    h_norm    = h / img_height
    return [x_center, y_center, w_norm, h_norm]

def yolo_to_pascal_voc(bbox, img_width, img_height):
    """Convert YOLO [x_c, y_c, w, h] normalized to Pascal VOC [x_min, y_min, x_max, y_max]."""
    x_c, y_c, w, h = bbox
    x_min = int((x_c - w / 2) * img_width)
    y_min = int((y_c - h / 2) * img_height)
    x_max = int((x_c + w / 2) * img_width)
    y_max = int((y_c + h / 2) * img_height)
    return [x_min, y_min, x_max, y_max]
```

**Labelling considerations:**
- Define clear rules for **occlusion** (partially hidden objects — label or skip?)
- Define rules for **truncation** (objects cut off at image border)
- Establish minimum object size thresholds — very small instances often add noise
- Crowd regions (`iscrowd=1` in COCO) need separate handling in loss computation

---

### 2.3 Semantic Segmentation

Assigns a **class label to every pixel** in the image. Unlike bounding boxes, semantic segmentation captures exact object boundaries — but does not distinguish between individual instances of the same class.

```
Every pixel in the image → one of: {road, sidewalk, car, pedestrian, sky, building, ...}
```

**Label format:** A single-channel mask image (PNG) where each pixel value is an integer corresponding to a class ID.

```python
import numpy as np
from PIL import Image

# Load a semantic segmentation mask
mask = np.array(Image.open("mask_001.png"))

# Each unique value corresponds to a class
unique_classes = np.unique(mask)
print(f"Classes present in image: {unique_classes}")
# e.g., [0, 1, 5, 7] → background, road, car, pedestrian
```

**Labelling considerations:**
- Polygon-based annotation tools are preferred over brush tools for crisp boundaries
- Boundary regions between classes are the hardest to label consistently — establish explicit overlap rules
- Requires significantly more annotator time than bounding box labelling (~10–30x slower)

---

### 2.4 Instance Segmentation

Extends semantic segmentation by distinguishing between **individual object instances** of the same class. Each car, each person, and each chair gets its own unique mask — not just a shared class label.

```
Semantic: all cars → class_id = 5
Instance: car_1 → instance_id = 5001
          car_2 → instance_id = 5002
          car_3 → instance_id = 5003
```

**COCO annotation format:**
```json
{
  "segmentation": [[x1, y1, x2, y2, x3, y3, ...]],  // polygon vertices
  "bbox": [x_min, y_min, width, height],
  "category_id": 3,
  "instance_id": 5001,
  "area": 4521
}
```

**Approach:** Polygon annotation (vertices clicked around the object boundary) is the standard method. SAM (Segment Anything Model) is increasingly used to **pre-annotate** polygons that humans then refine.

---

### 2.5 Keypoint / Pose Estimation

Annotators label specific **named coordinate points** on an object or body — capturing spatial configuration rather than shape.

**Human pose keypoints (COCO 17-keypoint schema):**

```
nose, left_eye, right_eye, left_ear, right_ear,
left_shoulder, right_shoulder, left_elbow, right_elbow,
left_wrist, right_wrist, left_hip, right_hip,
left_knee, right_knee, left_ankle, right_ankle
```

**COCO keypoint format:**
```json
{
  "keypoints": [x1, y1, v1, x2, y2, v2, ...],
  "num_keypoints": 17
}
```

Where `v` is the visibility flag:
- `0` — not labeled
- `1` — labeled but occluded
- `2` — labeled and visible

**Applications:** Human pose estimation, facial landmark detection, vehicle component localization, hand gesture recognition.

---

### 2.6 Video Annotation

Video labelling extends image annotation into the temporal dimension. The primary challenge is **tracking objects across frames** efficiently.

**Key techniques:**
- **Frame-by-frame annotation** — most accurate, most expensive
- **Keyframe interpolation** — annotate every N frames, interpolate between them
- **Object tracking + correction** — use a tracker to propagate boxes, humans correct drift

**Temporal label types:**
- **Action classification** — assign an action label to a video clip (Running / Jumping / Falling)
- **Temporal action localization** — identify the start/end frame of each action event
- **Video object tracking** — maintain consistent instance IDs across frames (MOT)

---

### Computer Vision Labelling Tools

| Tool | Type | Best For |
|---|---|---|
| **Label Studio** | Open-source | General CV annotation (bbox, polygon, keypoints) |
| **CVAT (Intel)** | Open-source | Object detection, segmentation, video tracking |
| **Roboflow** | SaaS | End-to-end CV pipeline: label → augment → train |
| **Labelbox** | Commercial | Enterprise CV annotation with QA workflows |
| **V7 Labs** | Commercial | Auto-annotation with model-assisted labelling |
| **Scale AI** | Managed service | High-volume, high-quality CV annotation |
| **SuperAnnotate** | SaaS | Fast polygon annotation + team management |

---

## Part 3: Labelling Strategies

### 3.1 Human Annotation

The gold standard. Subject-matter experts or trained crowd workers label data manually.

**Crowdsourcing platforms:**
- Amazon Mechanical Turk (MTurk)
- Scale AI, Labelbox, Appen
- In-house annotation teams

**Pros:** Highest quality when guidelines are clear and QA is rigorous.  
**Cons:** Expensive, slow, doesn't scale well to millions of samples.

---

### 3.2 Active Learning

Instead of labelling all data randomly, **train a model first, then selectively label only the samples the model is most uncertain about.** This dramatically reduces the number of labels needed to reach a target performance level.

```python
from modAL.models import ActiveLearner
from modAL.uncertainty import uncertainty_sampling
from sklearn.ensemble import RandomForestClassifier

# Initialize the active learner with a small labelled seed set
learner = ActiveLearner(
    estimator=RandomForestClassifier(),
    query_strategy=uncertainty_sampling,
    X_training=X_initial,
    y_training=y_initial
)

# Active learning loop
for iteration in range(20):
    query_idx, query_instance = learner.query(X_unlabelled)

    # Present query_instance to human annotator for labelling
    y_new = human_annotator_label(query_instance)  # Your annotation UI here

    # Teach the model the new label
    learner.teach(X_unlabelled[query_idx], y_new)
    X_unlabelled = np.delete(X_unlabelled, query_idx, axis=0)

    print(f"Iteration {iteration+1} | Accuracy: {learner.score(X_test, y_test):.3f}")
```

**Uncertainty sampling strategies:**
- **Least confidence** — label samples where the top predicted probability is lowest
- **Margin sampling** — label samples where the gap between top two predictions is smallest
- **Entropy sampling** — label samples with the highest prediction entropy across all classes

---

### 3.3 Weak Supervision & Programmatic Labelling

Instead of individual human labels, **define labelling functions** — simple heuristics, rules, or existing models — and combine them programmatically. The Snorkel framework pioneered this approach.

```python
from snorkel.labeling import labeling_function, PandasLFApplier, LFAnalysis
from snorkel.labeling.model import LabelModel

POSITIVE, NEGATIVE, ABSTAIN = 1, 0, -1

@labeling_function()
def lf_contains_positive_word(x):
    positive_words = ["great", "excellent", "love", "amazing", "perfect"]
    return POSITIVE if any(w in x.text.lower() for w in positive_words) else ABSTAIN

@labeling_function()
def lf_contains_negative_word(x):
    negative_words = ["terrible", "awful", "hate", "broken", "worst"]
    return NEGATIVE if any(w in x.text.lower() for w in negative_words) else ABSTAIN

@labeling_function()
def lf_short_text(x):
    # Short texts are often not informative enough — abstain
    return ABSTAIN if len(x.text.split()) < 4 else ABSTAIN

# Apply all LFs to the unlabelled dataset
lfs = [lf_contains_positive_word, lf_contains_negative_word, lf_short_text]
applier = PandasLFApplier(lfs=lfs)
L_train = applier.apply(df=df_unlabelled)

# Analyze LF coverage and conflict
print(LFAnalysis(L=L_train, lfs=lfs).lf_summary())

# Train a generative label model to combine LF outputs into probabilistic labels
label_model = LabelModel(cardinality=2, verbose=True)
label_model.fit(L_train=L_train, n_epochs=500, lr=0.001)
y_prob = label_model.predict_proba(L=L_train)
```

**Pros:** Can label millions of samples in minutes. No per-sample human cost.  
**Cons:** Label quality is lower than manual — use as training labels for a downstream model (not as ground truth for evaluation).

---

### 3.4 Model-Assisted / Auto-Annotation

Use a pre-trained model to **pre-label data**, then have humans review and correct. Dramatically accelerates annotation throughput for CV tasks.

```python
# Using SAM (Segment Anything Model) for CV pre-annotation
from segment_anything import sam_model_registry, SamAutomaticMaskGenerator

sam = sam_model_registry["vit_h"](checkpoint="sam_vit_h.pth")
mask_generator = SamAutomaticMaskGenerator(sam)

import cv2
image = cv2.imread("image.jpg")
image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)

# Generate candidate masks — humans then review and assign class labels
masks = mask_generator.generate(image)
print(f"Generated {len(masks)} candidate masks for human review")
```

**Human-in-the-loop workflow:**
1. Model pre-labels the batch
2. Human reviews and corrects — does not annotate from scratch
3. Corrected labels retrain the model
4. Model improves → faster, more accurate pre-labelling in the next iteration

---

## Part 4: Label Schema Design

Getting the labelling schema right before annotation starts is the most cost-effective investment in any ML project. Changing the schema mid-annotation means relabelling everything.

### Principles of Good Label Schema Design

**1. Mutually Exclusive (for single-label tasks)**  
Every sample should unambiguously fall into exactly one category. If annotators frequently debate which label applies, the schema needs refinement.

**2. Collectively Exhaustive**  
Every sample must have a valid label. An "Other" category is acceptable, but if it captures more than ~10% of data, the schema is likely underspecified.

**3. Operationally Definable**  
Every label must be definable in terms of observable characteristics — not internal states, intentions, or interpretations that vary by annotator.

**4. Task-Aligned**  
Labels should reflect what the downstream model actually needs to learn and predict. Overly fine-grained labels that a model can't meaningfully distinguish add cost without value.

### Label Documentation: The Annotation Guideline

Every production labelling project needs a written annotation guideline covering:

```
1. Task Definition
   - What is the model trying to predict?
   - Why does each label exist?

2. Label Definitions
   - Definition of each class with examples
   - Borderline and edge case rules

3. Decision Tree
   - Step-by-step logic for ambiguous cases

4. What NOT to Label
   - Explicit exclusion rules

5. Quality Standards
   - Minimum acceptable IAA
   - Review and escalation process
```

---

## Part 5: Common Labelling Challenges and Solutions

| Challenge | Description | Solution |
|---|---|---|
| **Annotator fatigue** | Quality degrades over long sessions | Limit session length, rotate tasks, use attention checks |
| **Label imbalance** | Rare classes have few examples | Oversample rare classes in annotation batches |
| **Subjectivity** | Inherently ambiguous tasks (sarcasm, emotion) | Use majority vote across 3+ annotators; report soft labels |
| **Domain drift** | Labels valid today may not be valid tomorrow | Schedule periodic label audits and re-annotation cycles |
| **Schema ambiguity** | Unclear boundaries between classes | Maintain a living annotation guideline with resolved examples |
| **Cost at scale** | Millions of samples to label | Combine active learning + weak supervision to reduce volume |
| **Annotation errors** | Mistakes, misclicks, fatigue-induced errors | Use Cleanlab, confidence-weighted sampling, or expert review |
| **Class confusion** | Annotators consistently confuse two classes | Refine definitions; add worked examples; retrain annotators |

---

## Part 6: Evaluation — When Are Labels Good Enough?

### Dataset Quality Checklist

```
□ IAA (Cohen's Kappa) ≥ 0.70 for all label types
□ Label error rate estimated via Cleanlab or manual audit < 3%
□ Class distribution in labelled set reflects expected production distribution
□ Edge cases and known failure modes are explicitly represented
□ Train / validation / test splits are stratified — no label leakage across splits
□ Annotation guidelines reviewed and signed off by domain expert
□ At least one round of annotator calibration completed before full annotation
□ Evaluation set labels reviewed by senior annotator or expert (not crowdsourced)
```

---

## Key Takeaways

| Concept | Summary |
|---|---|
| **Label quality > model complexity** | Clean labels beat clever architectures |
| **IAA before annotation at scale** | Run a calibration round on 50–100 samples first |
| **BIO scheme for NER** | Industry standard — B=Begin, I=Inside, O=Outside |
| **COCO vs YOLO vs VOC** | Different bbox formats for different frameworks — conversion is simple |
| **Active learning** | The most cost-efficient path from 0 to a labelled dataset |
| **Weak supervision** | Use for initial exploration or when data volume is massive |
| **SAM for CV** | Pre-annotation with Segment Anything slashes segmentation labelling time |
| **Schema design first** | Changing labels mid-project means relabelling everything |
| **Evaluation set is sacred** | Never use auto-annotation or weak supervision for your eval set |

---

## Further Reading & Resources

- Ratner, A. et al. (2017). *Snorkel: Rapid Training Data Creation with Weak Supervision.* VLDB.
- Kirillov, A. et al. (2023). *Segment Anything.* Meta AI Research. arXiv:2304.11490.
- Northcutt, C. et al. (2021). *Confident Learning: Estimating Uncertainty in Dataset Labels.* JAIR. arXiv:1911.00068. *(Cleanlab paper)*
- Lin, T.Y. et al. (2014). *Microsoft COCO: Common Objects in Context.* ECCV. *(The COCO annotation format standard)*
- Settles, B. (2009). *Active Learning Literature Survey.* University of Wisconsin-Madison.
- Liang, P.P. et al. (2022). *Advances, Challenges and Opportunities in Creating Data for Trustworthy AI.* Nature Machine Intelligence.
