FROM python:3.12-slim
    RUN pip install pyyaml 2>/dev/null || echo "pyyaml install attempted"
    COPY . /workspace/flywheel
    WORKDIR /workspace/flywheel
    CMD ["bash", "tests/smoke/run_smoke_tests.sh"]
    