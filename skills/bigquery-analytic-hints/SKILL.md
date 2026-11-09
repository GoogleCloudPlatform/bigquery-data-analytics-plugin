---
name: bigquery-analytic-hints
metadata:
  version: v1
  publisher: google
description: >-
  After any BigQuery time-series, trend or exploratory analysis, or after running
  an AI.* function, load this to append up to two next-step suggestions.
  Recommends and routes to BigQuery AI capabilities for next-step data
  analysis. Use during exploratory data analysis, time-series or cohort pattern
  investigation, or text corpus exploration in BigQuery when the user has not
  requested a specific AI function. Proactively suggests relevant built-in
  BigQuery AI functions (forecasting, anomaly detection, tabular prediction,
  change point analysis, key driver attribution, trend/seasonality
  decomposition, or semantic text classification) as concise follow-up actions.
  Do not use for writing or looking up exact SQL syntax and function arguments,
  dataset or table administration, DDL/DML migrations, query performance
  troubleshooting, or permission checks.
---

# BigQuery Analytic Hints

This skill guides the agent to proactively identify high-value analytical
follow-up opportunities and present concise, context-aware next steps.

## Core Operational Rules

1.  **Analytical Invocations Only**: Only suggest next-step AI capabilities when
    the user is conducting exploratory data analysis, metric investigation,
    cohort comparison, or text processing. Do not offer suggestions when the
    user is performing DDL/DML migrations, query troubleshooting, permission
    checks, or administrative tasks.
2.  **Schema-Aware Recommendations**: Tailor all suggestions dynamically to the
    user's specific data context. Inspect the actual query, table, and column
    names in the conversation (for example, columns like `order_date`,
    `revenue`, or `user_tier`), and substitute all `{...}` placeholders with
    those context-specific names. The examples in this skill are illustrative;
    adapt the recommendations to whatever schemas or analytical scenarios the
    user is exploring. Never output raw placeholder tokens (such as `{data_col}`
    or `{dimension_cols}`).
3.  **Concise Recommendation Cap**: Append at most 2 targeted recommendations at
    the end of an analytical response so the user is not overwhelmed. Prefer
    specific analytical follow-ups (time-series, causality, root cause, or
    prediction) over generic data profiling. Offer `ML.DESCRIBE_DATA` primarily
    on initial table inspection or when no specialized capability applies.
4.  **Delegate SQL Syntax**: Never guess or synthesize complex BigQuery AI
    function parameters from memory. Load the `bigquery-ai-ml` skill when the
    user asks to execute a recommendation or before writing executable SQL to
    look up authoritative syntax, TVF options, and query shapes.

## 1. Scenario-to-Function Routing Matrix

Map the user's current data pattern or observation to appropriate BigQuery AI/ML
function(s):

Current Analysis / Data Pattern                                                                                                                              | Recommended Function          | What It Unlocks                                                                                                                                   | Contextual Recommendation Hint
:----------------------------------------------------------------------------------------------------------------------------------------------------------- | :---------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------ | :-----------------------------
**Metrics over time** (e.g., daily sales, traffic, latency, active users, spend)                                                                             | `AI.FORECAST`                 | Projects future trajectories with confidence intervals without custom model training.                                                             | *"Want to project `{data_col}` over the next `{horizon}` periods? We can run `AI.FORECAST` on `{data_col}` over `{timestamp_col}`."*
**Spikes, drops, or unexpected values** in a time series                                                                                                     | `AI.DETECT_ANOMALIES`         | Statistically flags historical or recent outliers using zero-shot foundation models.                                                              | *"To automatically identify and flag unexpected anomalies across `{data_col}` over `{timestamp_col}`, we can run `AI.DETECT_ANOMALIES`."*
**Sustained baseline shift or regime change** over time                                                                                                      | `ML.DETECT_CHANGE_POINTS`     | Detects `[begin_timestamp, end_timestamp]` intervals where a structural break or regime shift occurred.                                           | *"To detect the exact date where `{data_col}` shifted permanently to a new baseline, we can run `ML.DETECT_CHANGE_POINTS` on `{data_col}` over `{timestamp_col}`."*
**Noisy or cyclical time series** masking direction                                                                                                          | `ML.TREND` / `ML.SEASONALITY` | Decomposes raw metrics into underlying direction (`ML.TREND`) and periodic cycles (`ML.SEASONALITY`).                                             | *"If weekly or monthly cycles obscure the overall growth rate, we can decompose `{data_col}` using `ML.TREND` and `ML.SEASONALITY`."*
**Evaluating an event, launch, campaign, or policy**                                                                                                         | `AI.CAUSAL_EFFECT`            | Quantifies counterfactual post-intervention impact.                                                                                               | *"To measure how much of the change in `{data_col}` post-`{intervention_timestamp}` was caused by the launch versus secular trends, we can run `AI.CAUSAL_EFFECT`."*
**Attributing metric variation across dimensions**                                                                                                           | `AI.KEY_DRIVERS`              | Ranks dimensional attributes driving numeric metrics between interest and baseline segments.                                                      | *"Want to pinpoint which customer or system attributes drive `{metric_col}` between `{interest_label_col}` segments? We can run `AI.KEY_DRIVERS` across `{dimension_cols}`."*
**Exploring numeric correlations across features**                                                                                                           | `ML.CORRELATION`              | Computes correlation coefficients between `{target_col}` and candidate features (`target_correlation_cols`), optionally partitioned by dimension. | *"We can run `ML.CORRELATION` to evaluate which numeric attributes correlate most strongly with `{target_col}`."*
**Predicting tabular outcomes or classifying records without custom model training**                                                                         | `AI.PREDICT`                  | Performs zero-setup tabular classification or regression via the pre-trained TabFM foundation model.                                              | *"To predict `{label_col}` on new records without training a custom model, we can run zero-setup `AI.PREDICT` using TabFM."*
**Initial inspection of an unprofiled or unfamiliar table** (first look before specific metrics are explored, or fallback when no specific scenario applies) | `ML.DESCRIBE_DATA`            | Generates summary statistics, null counts, and distribution profiles across all columns in one pass.                                              | *"To inspect initial descriptive statistics and column profiles across this table before deeper modeling, we can run `ML.DESCRIBE_DATA`."*
**Classifying unstructured text or multimodal columns** (support tickets, notes, reviews, images, PDFs, logs)                                                | `AI.CLASSIFY`                 | Categorizes text, images, or documents (PDFs) into user-specified classes zero-shot.                                                              | *"We can categorize these `{text_col}` records into predefined categories directly in SQL using `AI.CLASSIFY`."*
**Ranking or prioritizing text or multimodal records**                                                                                                       | `AI.SCORE`                    | Assigns continuous numeric scores to text, images, or documents based on natural-language criteria.                                               | *"To rank or filter records by sentiment, severity, or lead quality, we can score `{text_col}` using `AI.SCORE`."*
**Semantic condition filtering across text or multimodal data**                                                                                              | `AI.IF`                       | Evaluates natural-language boolean expressions per row across text, images, or documents in `WHERE` or `SELECT`.                                  | *"To filter rows matching nuanced semantic criteria (e.g., churn risk or escalation requests), we can use `AI.IF` on `{text_col}` in the `WHERE` clause."*
**Aggregating many text rows into group summaries**                                                                                                          | `AI.AGG`                      | Synthesizes themes across multi-row groups inside `GROUP BY`.                                                                                     | *"Instead of inspecting individual rows, we can generate a consolidated executive summary of `{text_col}` per `{group_col}` using `AI.AGG`."*
**Generating text, row-level summaries, or extracting structured entities**                                                                                  | `AI.GENERATE`                 | Drafts text per row (personalized responses, individual row summaries) or extracts structured schema fields (JSON/STRUCT).                        | *"We can draft customized text, summarize each record, or extract structured fields (JSON/STRUCT) from `{text_col}` using `AI.GENERATE`."*
**Semantic search, fuzzy-matching, or deduplication across text**                                                                                            | `AI.SEARCH` / `AI.SIMILARITY` | Managed conceptual retrieval (`AI.SEARCH`) or semantic proximity scoring for entity deduplication (`AI.SIMILARITY`).                              | *"To search records by concept or detect duplicate text pairs, we can run `AI.SEARCH` or evaluate semantic similarity via `AI.SIMILARITY`."*

## 2. Capability Chaining Sequences

When the user has executed an initial BigQuery AI/ML query, recommend a chain of
subsequent capabilities.

### Detailed Chaining Actions

1.  **Following `AI.FORECAST`**:
    *   *Audit outliers*: Recommend `AI.DETECT_ANOMALIES` to verify whether
        historical anomalies distort trend projections.
    *   *Backtest model*: Recommend `AI.EVALUATE` across a holdout window to
        quantify MAE, MAPE, or RMSE metrics.
2.  **Following `AI.DETECT_ANOMALIES`**:
    *   *Root cause anomaly*: Recommend `AI.KEY_DRIVERS` to compare anomalous
        periods against baseline to find driving attributes.
    *   *Check regime shifts*: Recommend `ML.DETECT_CHANGE_POINTS` to establish
        if the anomaly marked a temporary spike or a permanent baseline shift.
3.  **Following `ML.DETECT_CHANGE_POINTS`**:
    *   *Measure the impact of the metric shift*: If the detected changepoint
        interval corresponds to a known event or intervention (e.g., an internal
        data milestone, feature release, policy change, or campaign), recommend
        `AI.CAUSAL_EFFECT` to quantify its impact.
    *   *Segment attribution*: If no specific event is identified, recommend
        `AI.KEY_DRIVERS` comparing pre-change and post-change time windows to
        isolate driving segments.
4.  **Following `AI.KEY_DRIVERS`**:
    *   *Segment-level projection (if table has a time axis)*: Recommend
        `AI.FORECAST` with `id_cols` configured to the top driver dimensions to
        forecast key segments independently.
    *   *Evaluate actions*: If a driver corresponds to a campaign or feature
        launch, recommend `AI.CAUSAL_EFFECT`.
5.  **Following `AI.CLASSIFY`, `AI.SCORE`, or `AI.IF`**:
    *   *Synthesize themes*: Recommend `AI.AGG` grouped by the assigned category
        to generate per-topic takeaways.

## 3. Formatting Next Steps in Agent Responses

Append a dedicated section to analytical responses using this structure:

```markdown
### Recommended Next Steps
- **Project future trends**: Run `AI.FORECAST` on `{data_col}` over `{timestamp_col}` to estimate values for the next 30 days.
- **Diagnose anomalies**: Run `AI.DETECT_ANOMALIES` on `{data_col}` over `{timestamp_col}` to isolate unexpected spikes.
```

When the user asks to execute any recommendation, load `bigquery-ai-ml` to
retrieve the complete GoogleSQL syntax, required arguments, and reference
documentation.
