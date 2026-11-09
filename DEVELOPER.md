# DEVELOPER.md

This document provides instructions for setting up your development environment
and contributing to the BigQuery Data Analytics Gemini CLI Extension project.

## Prerequisites

Before you begin, ensure you have the following:

1.  **Gemini CLI:** Install the Gemini CLI version v0.6.0 or above. Installation
    instructions can be found on the official Gemini CLI documentation. You can
    verify your version by running `gemini --version`.
2.  **BigQuery Access** For testing data plane skills, you will need access to an active BigQuery dataset.

## Developing the Extension

### Running from Local Source

The development process involves installing the extension locally into the Gemini CLI to test changes.

1.  **Clone the Repository:**

    ```bash
    git clone https://github.com/GoogleCloudPlatform/bigquery-data-analytics-plugin.git
    cd bigquery-data-analytics
    ```

2.  **Install the Extension Locally:** Use the Gemini CLI to install the
    extension from your local directory.

    ```bash
    gemini extensions install .
    ```
    The CLI will prompt you to confirm the installation. Accept it to proceed.

3.  **Testing Changes:** After installing, start the Gemini CLI (`gemini`).
    You can now interact with the `bigquery-data-analytics` skills to manually test your changes
    against your connected database.

## Testing

### Automated Presubmit Checks

A GitHub Actions workflow (`.github/workflows/presubmit-tests.yml`) is triggered
for every pull request. This workflow primarily verifies that the extension can
be successfully installed by the Gemini CLI.

Currently, there are no automated unit or integration test suites
within this repository. All functional testing must be performed manually. All skills
are currently tested in the [MCP Toolbox GitHub](https://github.com/googleapis/mcp-toolbox).

### Automated Skill Evaluations (EvalBench)

This repository uses the [EvalBench framework](https://github.com/GoogleCloudPlatform/evalbench) to automatically evaluate the quality, multi-turn conversational capabilities, and skill execution of the extension.

Evaluations run automatically via Cloud Build (`cloudbuild.yaml`) on pull requests when the `ci:run-evals` or `autorelease: pending` label is applied. Because tests run against a live BigQuery dataset, credentials are securely injected by Secret Manager during CI.

#### Understanding Evaluation Files

All evaluation configurations and datasets are located in the [`evals/`](evals/) directory:

*   **Conversational Dataset (`dataset.json`):** Defines test scenarios for the model. Each scenario contains:
    *   `starting_prompt`: The initial prompt sent to the agent.
    *   `conversation_plan`: Instructions for the simulated user LLM to drive multi-turn interactions.
    *   `expected_trajectory`: The sequence of tool/skill calls expected to successfully complete the task.
*   **Run Configuration (`run_config.yaml`):** Configures the EvalBench orchestrator, target model configs, and qualitative/performance scorers (e.g., goal completion, behavioral metrics, latency, token consumption).

#### Maintaining and Adding Scenarios

When adding new skills or modifying existing behavior, you should add or update corresponding scenarios in the dataset file:

1.  Open `evals/dataset.json`.
2.  Add a new scenario block with a unique `id`, a clear `starting_prompt`, a detailed `conversation_plan`, and the `expected_trajectory` of tool calls.
3.  Apply the `ci:run-evals` label while creating your pull request to trigger the evaluation pipeline.
4.  The evaluation pipeline runs securely via Cloud Build. A maintainer will review the internal logs and results to verify your scenarios pass successfully.

### Other GitHub Checks

*   **License Header Check:** A workflow ensures all necessary files contain the
    proper license header.
*   **Conventional Commits:** This repository uses
    [Release Please](https://github.com/googleapis/release-please) to manage
    releases. Your commit messages must adhere to the
    [Conventional Commits](https://www.conventionalcommits.org/) specification.
*   **Dependency Updates:** [Renovate](https://github.com/apps/forking-renovate)
    is configured to automatically create pull requests for dependency updates.

## Building the Extension

The building process for this extension is handled automatically by the
automated workflows when a new release is created. Manual building is not required.

## Maintainer Information

### Team

The primary maintainers for this repository are defined in the
[`.github/CODEOWNERS`](.github/CODEOWNERS) file:

*   `@GoogleCloudPlatform/senseai-eco`
*   `@GoogleCloudPlatform/bigquery-data-analytics-plugin-maintainers`

### Releasing

The release process is automated using `release-please`. It consists of the manual merging of a Release PR.

#### Release Process

1.  **Release PR:** When commits with conventional commit headers (e.g., `feat:`,
    `fix:`) are merged into the `main` branch, `release-please` will
    automatically create or update a "Release PR".
2.  **Merge Release PR:** A maintainer approves and merges the Release PR. This
    action triggers `release-please` to create a new GitHub tag and a
    corresponding GitHub Release.
