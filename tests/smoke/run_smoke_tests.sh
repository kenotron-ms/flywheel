#!/bin/bash
    set -e
    echo "Running flywheel smoke tests..."
    echo ""
    bash "$(dirname "$0")/test_amplifier_bundle.sh"
    