---
name: inspect-eval-author
description: Author a new Inspect AI task (dataset → solver → scorer). Use when adding a custom eval to the project's eval suite.
---

## When to use

When adding a custom eval — assertion / judge / sandbox-isolated agentic.

## How

### Layout

```
eval/
  pyproject.toml
  eval/
    tasks/
      my_task.py          <- @task function returning a Task
    datasets/
      my_task.jsonl       <- {input, target} per line
```

### The task

```python
from inspect_ai import Task, task
from inspect_ai.dataset import json_dataset
from inspect_ai.scorer import includes
from inspect_ai.solver import generate

@task
def my_task():
    return Task(
        dataset=json_dataset("eval/datasets/my_task.jsonl"),
        solver=generate(),
        scorer=includes(),
    )
```

### Sandbox-isolated agentic task

```python
from inspect_ai import Task, task
from inspect_ai.solver import use_tools, generate
from inspect_ai.tool import bash_session, text_editor

@task
def agentic_task():
    return Task(
        dataset=json_dataset("eval/datasets/agentic.jsonl"),
        solver=[
            use_tools([bash_session(), text_editor()]),
            generate(max_turns=10),
        ],
        scorer=includes(),
        sandbox=("docker", "compose.yaml"),
    )
```

### Run

```bash
uv run inspect eval eval/tasks/my_task.py --model anthropic/claude-opus-4-7
```

## Anti-patterns this skill prevents

- Hand-rolling eval harnesses for things `inspect_evals` already covers.
- Skipping `sandbox=` on agentic evals — without isolation, agents
  cross-contaminate.
- Datasets without `target` — `includes` and `match` scorers need a
  ground truth.
