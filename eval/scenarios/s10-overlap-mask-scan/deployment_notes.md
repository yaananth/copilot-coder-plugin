# Deployment Notes

The current assignment pipeline is `request_handler.py` to `pipeline.py`.

An optional batch executor is maintained separately for legacy protocol version 1.
That protocol accepts fixed-length identifiers only. This fixture does not establish
that current assignment traffic reaches the legacy executor.
