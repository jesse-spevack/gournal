# Gournal

A digital bullet journal that captures the authentic feel of writing on Japanese paper with fountain pen ink.

[![Wet Hot American Summer Gurnal](https://img.youtube.com/vi/7oZgCaplvtQ/0.jpg)](https://www.youtube.com/watch?v=7oZgCaplvtQ)

## Performance Features

### HTTP Caching

Gournal implements intelligent HTTP caching using ETags and Last-Modified headers to optimize performance:

- **Smart Cache Invalidation**: Automatically detects when habit data changes across devices
- **Bandwidth Optimization**: Returns 304 Not Modified responses when data hasn't changed
- **Cross-Device Sync**: Ensures fresh data is delivered when habits are updated on other devices
- **Real-Time Updates**: Cache invalidates instantly when you or others modify habit data

**Technical Implementation:**
- ETags generated from habit and entry data fingerprints
- Last-Modified headers track most recent data changes
- Automatic cache invalidation on all data mutations
- Comprehensive test coverage for cache behavior

This results in faster page loads for unchanged data while maintaining real-time accuracy when data is modified.

For implementation details, see `PROJECT_CONTEXT.md`.