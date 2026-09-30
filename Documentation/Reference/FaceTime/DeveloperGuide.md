# FaceTime Developer Guide

Use package-local tests for FaceTime changes:

```bash
swift test --filter FaceTime
```

Call initiation must remain explicit; execution requires `--allow-external-dispatch`.
