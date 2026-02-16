# PostgreSQL Declarative Partitioning Examples

This repository contains examples and demonstrations of PostgreSQL's declarative partitioning features. It serves as a companion to my blog post on PostgreSQL declarative partitioning.

## Blog Reference

For a detailed explanation of the concepts demonstrated in this repository, please visit my blog at: https://sohardh.com/blog-post/postgres-declarative-partitioning/

## Project Structure

The examples are organized into the following directories:

### 01_basics
- **01_range.sql**: Examples of RANGE partitioning with queries demonstrating partition pruning
- **02_list.sql**: Examples of LIST partitioning
- **03_hash.sql**: Examples of HASH partitioning

### 02_advanced
- **01_subpartitioning.sql**: Examples of multi-level partitioning (subpartitioning)
- **02_row_movement.sql**: Examples of row movement between partitions

### 03_pruning_tests
- **01_static_vs_dynamic.sql**: Examples demonstrating static vs dynamic partition pruning

## Getting Started

This project includes a Docker Compose file to set up a PostgreSQL 18 environment:

```bash
docker-compose up -d
```

The database will be accessible at localhost:5432 with the following credentials:
- Database: partitioning_demo
- Username: postgres
- Password: postgres

You can then run the SQL scripts in the order of the directories to explore the different partitioning techniques.
