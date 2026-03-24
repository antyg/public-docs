---
title: "Python Development"
status: "planned"
last_updated: "2026-03-16"
audience: "Python Developers, Automation Engineers"
document_type: "readme"
domain: "development"
---

# Python Development

Python development standards, best practices, and patterns for automation, API integration, data processing, and tooling within the workspace.

---

## Planned Content

### Code Style and Formatting

- [PEP 8](https://peps.python.org/pep-0008/) — Style guide for Python code: indentation (4 spaces), line length (88 characters with Black), naming conventions (snake_case for functions/variables, PascalCase for classes, UPPER_CASE for constants)
- [PEP 257](https://peps.python.org/pep-0257/) — Docstring conventions: module, class, and function docstrings
- [Black](https://black.readthedocs.io/) — Opinionated code formatter; non-negotiable formatting
- [Ruff](https://docs.astral.sh/ruff/) — Fast linter replacing Flake8, isort, pyupgrade; configured via `pyproject.toml`
- Pre-commit hooks enforcing Black and Ruff on every commit

### Type Hints and Static Analysis

- [PEP 484](https://peps.python.org/pep-0484/) — Type hints for function signatures and variable annotations
- [mypy](https://mypy.readthedocs.io/) — Static type checker; strict mode recommended for new code
- [PEP 526](https://peps.python.org/pep-0526/) — Variable annotation syntax
- Return type annotation patterns: `-> None`, `-> list[str]`, `-> dict[str, Any]`
- `Optional[T]` vs `T | None` (PEP 604, Python 3.10+)

### Virtual Environment and Dependency Management

- [uv](https://docs.astral.sh/uv/) — Preferred package and project manager (replaces pip + venv + pip-tools)
- `pyproject.toml` — Single source of truth for project metadata, dependencies, and tool configuration ([PEP 518](https://peps.python.org/pep-0518/), [PEP 621](https://peps.python.org/pep-0621/))
- Dependency pinning strategy: direct dependencies in `[project.dependencies]`, pinned lockfile via `uv lock`
- Development dependencies in `[project.optional-dependencies]` or `[dependency-groups]` (PEP 735)
- Virtual environment location: `.venv/` at project root (gitignored)

### Testing

- [pytest](https://docs.pytest.org/) — Preferred testing framework
- Test file naming: `test_<module>.py` in `tests/` directory
- Fixture patterns: `conftest.py` for shared fixtures
- Coverage: minimum 80% for critical modules via `pytest-cov`
- Parametrised tests with `@pytest.mark.parametrize`
- Mocking with `unittest.mock` or `pytest-mock`
- Integration test separation via pytest markers (`@pytest.mark.integration`)

### Documentation Standards

- Docstring style: [Google style](https://google.github.io/styleguide/pyguide.html#383-functions-and-methods) or [NumPy style](https://numpydoc.readthedocs.io/en/latest/format.html) — consistent within a project
- Required docstring sections: summary, Args, Returns, Raises
- [Sphinx](https://www.sphinx-doc.org/) or [MkDocs](https://www.mkdocs.org/) for module documentation generation
- `README.md` with installation, quick-start, and API overview

### Azure SDK for Python

- [azure-identity](https://learn.microsoft.com/en-us/python/api/overview/azure/identity-readme) — `DefaultAzureCredential` for local and CI environments
- [azure-mgmt-*](https://learn.microsoft.com/en-us/azure/developer/python/) — Management plane SDKs
- [msgraph-sdk-python](https://github.com/microsoftgraph/msgraph-sdk-python) — Microsoft Graph API client
- Async patterns with `asyncio` and `aiohttp` for high-throughput API work
- Rate limiting and retry patterns using `tenacity` or SDK built-ins

### CI/CD Integration

- Lint and format checks in PR gate (Ruff, Black --check, mypy)
- Pytest with coverage report in build pipeline
- Azure Pipelines YAML and GitHub Actions examples
- Artefact publishing to Azure Artifacts or PyPI

---

## Related Resources

- [PEP 8 — Style Guide for Python Code](https://peps.python.org/pep-0008/)
- [PEP 257 — Docstring Conventions](https://peps.python.org/pep-0257/)
- [PEP 484 — Type Hints](https://peps.python.org/pep-0484/)
- [Black Documentation](https://black.readthedocs.io/)
- [Ruff Documentation](https://docs.astral.sh/ruff/)
- [uv Documentation](https://docs.astral.sh/uv/)
- [pytest Documentation](https://docs.pytest.org/)
- [mypy Documentation](https://mypy.readthedocs.io/)
- [Azure SDK for Python](https://learn.microsoft.com/en-us/azure/developer/python/)
- [Microsoft Graph SDK for Python](https://github.com/microsoftgraph/msgraph-sdk-python)
